#!/usr/bin/env python3
import socket
import serial

# ==============================
# UART 설정 (Pi -> STM32)
# ==============================
UART_PORT = "/dev/ttyAMA0"   # 필요 시 "/dev/ttyS0"
UART_BAUD = 115200

ser = serial.Serial(
    port=UART_PORT,
    baudrate=UART_BAUD,
    timeout=1
)

print("UART opened:", UART_PORT, UART_BAUD)

# ==============================
# Android -> STM32 명령 매핑
# ==============================
# Android가 보내는 문자 -> STM32가 이해하는 wasdqef
CMD_MAP = {
    'W': 'W',   # 전진
    'S': 'S',   # 후진
    'A': 'A',   # 좌회전
    'D': 'D',   # 우회전
    'F': 'F',   # 정지
    'Q': 'Q',   # 비상정지
    'E': 'E',   # 비상정지 해제
}

# ==============================
# TCP 서버 설정 (Android 접속)
# ==============================
HOST = "0.0.0.0"
PORT = 9999

srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
srv.bind((HOST, PORT))
srv.listen(5)

print("TCP server listening on port", PORT)

# ==============================
# 메인 루프
# ==============================
while True:
    conn, addr = srv.accept()
    print("Connected from", addr)

    try:
        while True:
            data = conn.recv(1024)
            if not data:
                break

            # Android에서 온 명령
            cmd = data.decode(errors="ignore").strip().upper()
            print("TCP:", cmd)

            if cmd in CMD_MAP:
                uart_cmd = CMD_MAP[cmd]
                print("UART:", uart_cmd)
                match uart_cmd:
                    case 'W':
                        print("\n---------전진----------\n")
                    case 'S':
                        print("\n---------후진----------\n")
                    case 'A':
                        print("\n---------좌회전---------\n")
                    case 'D':
                        print("\n---------우회전---------\n")
                    case 'F':
                        print("\n---------정지----------\n")
                    case 'Q':
                        print("\n--------비상정지--------\n")
                    case 'E':
                        print("\n--------비상해제--------\n")
                    case _:
                        print("\n--------알 수 없는 명령:", uart_cmd,"--------\n")

                ser.write(uart_cmd.encode())
                ser.flush()
            else:
                print("Unknown command:", cmd)

    except Exception as e:
        print("Error:", e)

    finally:
        conn.close()
        print("Connection closed")
