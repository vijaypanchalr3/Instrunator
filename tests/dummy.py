import socket
import threading

def handle_client(conn, addr):
    print(f"Connected: {addr}")
    with conn:
        while True:
            try:
                data = conn.recv(1024).decode().strip()
                if not data:
                    break
                print(f">> {data}")
                if data == "*IDN?":
                    conn.sendall(b"FakeCorp,FakeModel,1234,1.0\n")
                elif data == "MEAS:VOLT?":
                    conn.sendall(b"3.1415\n")
                else:
                    conn.sendall(b"ERROR\n")
            except Exception as e:
                print("Error:", e)
                break

def run_server():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind(('127.0.0.1', 5025))
    server.listen()
    print("Fake VISA instrument on TCP port 5025")
    while True:
        conn, addr = server.accept()
        threading.Thread(target=handle_client, args=(conn, addr), daemon=True).start()

if __name__ == "__main__":
    run_server()