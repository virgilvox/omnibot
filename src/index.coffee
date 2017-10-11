five = require 'johnny-five'
BLESerialPort = require('ble-serial').SerialPort
Firmata = require('firmata').Board

board = new five.Board({
    io: new Firmata new BLESerialPort({})
  })

board.on 'ready', () =>
  configs = five.Motor.SHIELD_CONFIGS.ADAFRUIT_V2
  m1 = new five.Motor configs.M1
  m2 = new five.Motor configs.M3
  m3 = new five.Motor configs.M4

  m1.start 0
  m2.start 0
  m3.start 0

  @motors = [ m1, m2, m3 ]
  drive 100, 0

drive = (x, y) =>
  vector = cartesianToPolar  x, y
  speeds = calculateSpeeds vector
  driveMotors @motors, speeds

driveMotors = (motors, speeds) =>
  motors.forEach (motor, i) =>
    speed = mapRange Math.abs(speeds[i])
    sign = Math.sign speeds[i]
    
    motor.forward speed if sign == 1
    motor.reverse speed if sign == -1
    motor.stop if sign == 0

cartesianToPolar = (x, y) =>
  theta = Math.atan2 y, x
  r = Math.sqrt(y*y + x*x)
  return { r, theta }

calculateSpeeds = ({ r, theta }) =>
  vx = Math.cos(theta) * r
  vy = Math.sin(theta) * r

  w1 = - vx
  w2 = (0.5 * vx) - (Math.sqrt(3/2) * vy)
  w3 = (0.5 * vx) + (Math.sqrt(3/2) * vy)

  return [ w1, w2, w3 ]

mapRange = (n) =>
  n = Math.ceil((n * 255) / 122.4744871391589)
  return n unless n > 255
  255
