#!/usr/bin/env python3
import time

import psutil
import ctypes
from pathlib import Path
from io import BytesIO

libc = ctypes.CDLL("libc.so.6")
libc.ptrace.argtypes = [ctypes.c_uint64, ctypes.c_uint64, ctypes.c_void_p, ctypes.c_void_p]
libc.ptrace.restype = ctypes.c_uint64


PROC_NAMES = ["cc2", "cc2.exe", "carrier_command", "carrier_command.exe"]
PTRACE_PEEKTEXT   = 1
PTRACE_PEEKDATA   = 2
PTRACE_POKETEXT   = 4
PTRACE_POKEDATA   = 5
PTRACE_CONT       = 7
PTRACE_SINGLESTEP = 9
PTRACE_GETREGS    = 12
PTRACE_SETREGS    = 13
PTRACE_ATTACH     = 16
PTRACE_DETACH     = 17

def find_game() -> psutil.Process:
    found = {}

    for proc in psutil.process_iter(["pid", "name"]):
        if proc.info["name"] in PROC_NAMES:
            found[proc.info["name"]] = proc

    # prefer cc2 (i use this on linux with carrier_command actually being a cmd.exe
    game = None
    for name in PROC_NAMES:
        if name in found:
            game = found[name]
            break
    return game

magic = b"txbufferstart"


def get_procfile(pid: int) -> Path:
    return Path("/proc") / str(pid) / "mem"


def read_region(pid, mem_start, mem_size) -> bytes:
    with get_procfile(pid).open("rb") as mem:
        mem.seek(mem_start)
        return mem.read(mem_size)


def read_buffers(pid, mem_start, mem_size) -> bytes:
    buf = read_region(pid, mem_start, mem_size)
    if buf:
        start = buf.find(magic)
        if start > 0:
            return buf
    return b""


def scan_heap(pid, mem_start, mem_size) -> bytes:
    try:
        return read_buffers(pid, mem_start, mem_size)
    except OSError:
        pass
    return b""

def decode_header(fragment: bytes) -> int:
    try:
        text = fragment.decode("utf-8")
        if len(text) == 18:
            length = int(text[-5:-1], 16)
            return length
    except (UnicodeDecodeError, ValueError):
        return 0


def get_mapped_size(pid, get_start) -> int:
    proc = psutil.Process(pid)
    maps = proc.memory_maps(grouped=False)
    for m in maps:
        if m.perms.startswith("r"):
            addr = m.addr
            if "-" in addr:
                start, end = addr.split("-")
                mem_start = int(start, 16)
                if mem_start == get_start:
                    mem_end = int(end, 16)
                    return mem_end - mem_start
    return 0

def seek_next_packet(fd) -> bool:
    readsize = 64 * 1024
    found = -1
    while True:
        offset = fd.tell()
        chunk = fd.read(readsize)
        if not chunk:
            break
        found = chunk.find(magic)
        if found > 0:
            offset = offset + found
            fd.seek(offset)
            break
    return found > -1

def scan_game(game: psutil.Process):
    if not game:
        print("no game running", flush=True)
        return
    proc = psutil.Process(game.pid)
    maps = proc.memory_maps(grouped=False)
    buf = None
    mem_start = 0
    mem_size = 0
    # find the heap region with the telemetry string in
    for m in maps:
        if m.perms.startswith("r"):
            addr = m.addr
            if "-" in addr:
                start, end = addr.split("-")
                mem_start = int(start, 16)
                mem_end = int(end, 16)
                mem_size = mem_end - mem_start

                if mem_size and mem_start:
                    buf = scan_heap(proc.pid, mem_start, mem_size)
        if buf:
            break

    if buf and mem_start and mem_size:
        print(f"found {game.pid} memory region {mem_start} ({mem_size} bytes)")
        # monitor this region of memory

        while True:
            rxdata = []
            time.sleep(1)

            t1 = time.monotonic()
            mem_size = get_mapped_size(game.pid, mem_start)
            print(f"scanning.. {mem_size} bytes")
            rxbuf = scan_heap(game.pid, mem_start, mem_size)
            t2 = time.monotonic()

            with BytesIO(rxbuf) as fd:
                # find all telemetry buffers in the memory area
                found = seek_next_packet(fd)
                if not found:
                    # no packet
                    continue

                while True:
                    hdr = fd.read(18)
                    length = decode_header(hdr)
                    if length:
                       payload = fd.read(length)
                       rxdata.append(payload.decode())
                    else:
                        if not seek_next_packet(fd):
                            # no more packets
                            break

            if len(rxdata):
                print(f"{t2-t1:2.2f} {mem_start:08x} ({mem_size} bytes) {len(rxdata)}")
                for item in rxdata:
                    print(item)

    else:
        print("no buffer found", flush=True)


if __name__ == "__main__":
    scan_game(find_game())