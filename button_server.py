import socket
import gpiod
import time

SERVER_IP = "127.0.0.1"
SERVER_PORT = 4242

# Pins that the program uses
# Change these if you intend to use other pins
LIGHT_PIN = 23
BTN_PIN = 24

# -- Setup hardware -- 
chip = gpiod.Chip("gpiochip4")

lightLine = chip.get_line(LIGHT_PIN)
lightLine.request(consumer="LED", type=gpiod.LINE_REQ_DIR_OUT)

buttonLine = chip.get_line(BTN_PIN)
buttonLine.request(consumer="Button", type=gpiod.LINE_REQ_DIR_IN)

# For making sure the button is only triggered once when pressed
buttonPressed = False

# -- Setup networking --
clientSocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

print("Running...")


def onButtonPressed():
	clientSocket.sendto("Hello from Python".encode(), (SERVER_IP, SERVER_PORT))
	data, (recv_ip, recv_port) = clientSocket.recvfrom(1024)
	print(f"ReceivedL '{data.decode()}' {recv_ip}:{recv_port}")


try:
	while True:
		buttonState = buttonLine.get_value()
		if buttonState == 1:
			lightLine.set_value(1)
			
			if not buttonPressed:
				buttonPressed = True
				onButtonPressed()
		else:
			buttonPressed = False
			lightLine.set_value(0)

		time.sleep(0.016)
finally:
	lightLine.release()
buttonLine.release()
		 
