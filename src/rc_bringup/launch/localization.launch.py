from launch import LaunchDescription
from launch_ros.actions import Node
from launch.actions import TimerAction, ExecuteProcess


def generate_launch_description():

    map_server = Node(
        package='nav2_map_server',
        executable='map_server',
        output='screen',
        parameters=[{
            'yaml_filename': '/home/bhh/ydlidar_slam_ws/maps/my_map.yaml'
        }]
    )

    amcl = Node(
        package='nav2_amcl',
        executable='amcl',
        output='screen',
        parameters=['/home/bhh/ydlidar_slam_ws/src/slam_configs/amcl.yaml']
    )

    lifecycle_manager = Node(
        package='nav2_lifecycle_manager',
        executable='lifecycle_manager',
        output='screen',
        parameters=[{
            'use_sim_time': False,
            'autostart': True,
            'node_names': ['map_server', 'amcl']
        }]
    )

    # 🔥 AMCL 활성화 후 global localization 자동 호출
    global_localization = TimerAction(
        period=4.0,   # AMCL fully active 대기 시간
        actions=[
            ExecuteProcess(
                cmd=[
                    'ros2',
                    'service',
                    'call',
                    '/reinitialize_global_localization',
                    'std_srvs/srv/Empty',
                    '{}'
                ],
                output='screen'
            )
        ]
    )

    return LaunchDescription([
        map_server,
        amcl,
        lifecycle_manager,
        global_localization
    ])