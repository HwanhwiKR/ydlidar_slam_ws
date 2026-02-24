import socket

HOST = "0.0.0.0"
PORT = 9999

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind((HOST, PORT))
s.listen(5)

print("TCP Server started, waiting for connections...")

while True:
    conn, addr = s.accept()
    print("Connected from", addr)

    try:
        while True:
            data = conn.recv(1024)
            if not data:
                break
            cmd = data.decode().strip()
            print("Received:", cmd)

            # TODO: 여기서 UART로 STM32에 전달
            # ser.write(cmd.encode())

    except Exception as e:
        print("Error:", e)

    finally:
        conn.close()
        print("Connection closed")
