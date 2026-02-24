from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():
    return LaunchDescription([

        Node(
            package='slam_toolbox',
            executable='sync_slam_toolbox_node',
            output='screen',
            parameters=[{
                'use_sim_time': False,
                'map_frame': 'map',
                'odom_frame': 'odom',
                'base_frame': 'base_link',
                'scan_topic': '/scan',
                'publish_tf': True,
                'resolution': 0.05,
                'max_laser_range': 12.0
            }]
        ),
    ])