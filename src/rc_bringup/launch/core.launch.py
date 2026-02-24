from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():
    return LaunchDescription([

        Node(
            package='ydlidar_ros2_driver',
            executable='ydlidar_ros2_driver_node',
            output='screen',
            parameters=[{
                'port': '/dev/ttyUSB0',
                'frame_id': 'laser_frame',
                'baudrate': 128000,
                'lidar_type': 1,
                'device_type': 0,
                'isSingleChannel': True,
                'sample_rate': 5,
                'frequency': 5.0,
                'fixed_resolution': True,
                'reversion': False,
                'inverted': True,
                'auto_reconnect': True,
                'support_motor_dtr': False,
                'intensity': False,
                'abnormal_check_count': 4,
                'range_min': 0.05,
                'range_max': 12.0
            }]
        ),

        Node(
            package='robot_state_publisher',
            executable='robot_state_publisher',
            arguments=['/home/bhh/ydlidar_slam_ws/src/rc_description/urdf/rc_base.urdf'],
            output='screen'
        ),

        Node(
            package='mpu6050_imu',
            executable='imu_node',
            output='screen'
        ),

        Node(
            package='rf2o_laser_odometry',
            executable='rf2o_laser_odometry_node',
            output='screen',
            parameters=[{
                'laser_scan_topic': '/scan',
                'odom_topic': '/odom_rf2o',
                'base_frame_id': 'base_link',
                'odom_frame_id': 'odom',
                'publish_tf': False,
                'freq': 5.0
            }]
        ),

        Node(
            package='robot_localization',
            executable='ekf_node',
            output='screen',
            parameters=['/home/bhh/ydlidar_slam_ws/src/slam_configs/ekf.yaml']
        ),
    ])