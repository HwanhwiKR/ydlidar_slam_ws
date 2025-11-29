from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():
    talker_node = Node(
        package='py_pubsub',
        executable='talker',
        name='minimal_publisher',
        output='screen',
        emulate_tty=True,
        parameters=[{}]
    )

    listener_node = Node(
        package='py_pubsub',
        executable='listener',
        name='minimal_subscriber',
        output='screen',
        emulate_tty=True
    )

    return LaunchDescription([
        talker_node,
        listener_node,
    ])
