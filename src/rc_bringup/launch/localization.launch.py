from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():
    return LaunchDescription([

        Node(
            package='nav2_map_server',
            executable='map_server',
            output='screen',
            parameters=[{
                'yaml_filename': '/home/bhh/ydlidar_slam_ws/maps/my_map.yaml'
            }]
        ),

        Node(
            package='nav2_amcl',
            executable='amcl',
            output='screen',
            parameters=['/home/bhh/ydlidar_slam_ws/src/slam_configs/amcl.yaml']
        ),

        Node(
            package='nav2_lifecycle_manager',
            executable='lifecycle_manager',
            output='screen',
            parameters=[{
                'use_sim_time': False,
                'autostart': True,
                'node_names': ['map_server', 'amcl']
            }]
        ),
    ])