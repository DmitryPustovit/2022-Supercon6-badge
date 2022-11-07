import sys
import serial


ser = serial.Serial(sys.argv[1], 9600) # '/dev/tty.usbserial-110'

try:
    while True:
        data = ser.read_all()
        if data:
            print("Received: %s." % data)
            ser.write(data)

except KeyboardInterrupt:
    print("Done.")

except:
    raise

finally:
    ser.close()
    print ("Closed port.") 