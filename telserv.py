#!/usr/bin/env python3
import socket
import sys
import socketserver
import time
import subprocess
from threading import Thread, Lock

class Game(Thread):
    def __init__(self, args: list[str], server: socketserver.ThreadingTCPServer):
        super().__init__(daemon=True)
        self.server = server
        self.args: list[str] = args
        self.proc: subprocess.Popen | None = None
        self.lck = Lock()
        self.clients: list[socket.socket] = []

    def add_client(self, sock):
        with self.lck:
            self.clients.append(sock)

    def remove_client(self, sock):
        with self.lck:
            self.clients.remove(sock)

    def run(self):
        print(self.server)
        self.proc = subprocess.Popen(self.args,
                                     shell=False, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, stdin=subprocess.DEVNULL)

        for line in self.proc.stdout:
            if line and line.startswith(b"A"):
                # send to all clients
                with self.lck:
                    for client in self.clients:
                        client: socket.socket
                        try:
                            client.sendall(line)
                        except ConnectionError:
                            continue

        print(f"Game exited server={self.server}")
        if self.server:
            print("Calling shutdown..")
            self.server.shutdown()
            with self.lck:
                for sock in self.clients:
                    print("close connection..")
                    sock.close()


class GameHandler(socketserver.BaseRequestHandler):
    game: Game | None = None
    clients = []

    def handle(self):
        print("client connected")
        self.game.add_client(self.request)
        sock: socket.socket = self.request
        sock.settimeout(1)
        while self.game.proc.poll() is None:
            try:
                sock.recv(1)
            except ConnectionError:
                break
            except TimeoutError:
                pass

    def finish(self):
        print("client disconnected")
        self.game.remove_client(self.request)


def run_server():

    with socketserver.ThreadingTCPServer(("localhost", 6767), GameHandler, bind_and_activate=True) as server:
        game = Game(sys.argv[1:], server)
        game.start()

        print(f"server = {server}")
        GameHandler.game = game
        GameHandler.server = server
        print("Starting server..")
        server.serve_forever()

run_server()