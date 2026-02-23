import rclpy
from rclpy.node import Node
from sensor_msgs.msg import Imu
import smbus
import math
import time

MPU_ADDR = 0x68
PWR_MGMT_1 = 0x6B
GYRO_ZOUT_H = 0x47


class MPU6050Node(Node):

    def __init__(self):
        super().__init__('mpu6050_node')

        self.publisher_ = self.create_publisher(Imu, '/imu', 10)
        self.timer = self.create_timer(0.02, self.publish_imu)  # 50Hz

        self.bus = smbus.SMBus(1)
        self.bus.write_byte_data(MPU_ADDR, PWR_MGMT_1, 0)

        # ----- Bias Calibration -----
        self.calibrating = True
        self.bias_sum = 0.0
        self.bias_count = 0
        self.bias = 0.0
        self.calibration_start_time = time.time()

        # ----- Low Pass Filter -----
        self.filtered_gyro = 0.0
        self.alpha = 0.95   # 높을수록 부드러움 (0.90~0.98 추천)

        self.get_logger().info("MPU6050 IMU Node Started")
        self.get_logger().info("Calibrating gyro bias for 10 seconds... Keep robot still.")

    def read_word(self, reg):
        high = self.bus.read_byte_data(MPU_ADDR, reg)
        low = self.bus.read_byte_data(MPU_ADDR, reg + 1)
        value = (high << 8) + low
        if value >= 0x8000:
            value = -((65535 - value) + 1)
        return value

    def publish_imu(self):
        # raw gyro (deg/s)
        raw_gyro_z = self.read_word(GYRO_ZOUT_H) / 131.0
        gyro_z_rad = math.radians(raw_gyro_z)

        # ----- Bias Calibration Phase -----
        if self.calibrating:
            self.bias_sum += gyro_z_rad
            self.bias_count += 1

            if time.time() - self.calibration_start_time >= 10.0:
                self.bias = self.bias_sum / self.bias_count
                self.calibrating = False
                self.get_logger().info(
                    f"Gyro bias calibrated: {self.bias:.8f} rad/s")

            return  # 보정 중에는 publish 안함

        # ----- Bias 제거 -----
        gyro_z_corrected = gyro_z_rad - self.bias

        # ----- Deadband -----
        if abs(gyro_z_corrected) < 0.005:
            gyro_z_corrected = 0.0

        # ----- Low Pass Filter -----
        self.filtered_gyro = (
            self.alpha * self.filtered_gyro +
            (1.0 - self.alpha) * gyro_z_corrected
        )

        # ----- IMU Message -----
        msg = Imu()
        msg.header.stamp = self.get_clock().now().to_msg()
        msg.header.frame_id = "base_link"

        msg.angular_velocity.z = self.filtered_gyro

        # EKF 안정화용 covariance
        msg.angular_velocity_covariance[0] = 0.0
        msg.angular_velocity_covariance[4] = 0.0
        msg.angular_velocity_covariance[8] = 0.00002

        self.publisher_.publish(msg)


def main(args=None):
    rclpy.init(args=args)
    node = MPU6050Node()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()