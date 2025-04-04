import subprocess

def create_topic(topic_name, partitions=1, replication_factor=1):
    command = [
        '/home/anurag/vscode/infra/kafka_2.13-3.8.0/bin/kafka-topics.sh', '--create', '--topic', topic_name,
        '--bootstrap-server', 'localhost:9092',
        '--partitions', str(partitions),
        '--replication-factor', str(replication_factor)
    ]
    subprocess.run(command)

def list_topics():
    command = [
        '/home/anurag/vscode/infra/kafka_2.13-3.8.0/bin/kafka-topics.sh', '--list',
        '--bootstrap-server', 'localhost:9092'
    ]
    subprocess.run(command)

def delete_topic(topic_name):
    command = [
        '/home/anurag/vscode/infra/kafka_2.13-3.8.0/bin/kafka-topics.sh', '--delete', '--topic', topic_name,
        '--bootstrap-server', 'localhost:9092'
    ]
    subprocess.run(command)

def describe_topic(topic_name):
    command = [
        '/home/anurag/vscode/infra/kafka_2.13-3.8.0/bin/kafka-topics.sh', '--describe', '--topic', topic_name,
        '--bootstrap-server', 'localhost:9092'
    ]
    subprocess.run(command)

def list_consumer_groups():
    command = [
        '/home/anurag/vscode/infra/kafka_2.13-3.8.0/bin/kafka-consumer-groups.sh', '--list',
        '--bootstrap-server', 'localhost:9092'
    ]
    subprocess.run(command)

def describe_consumer_group(group_id):
    command = [
        '/home/anurag/vscode/infra/kafka_2.13-3.8.0/bin/kafka-consumer-groups.sh', '--describe', '--group', group_id,
        '--bootstrap-server', 'localhost:9092'
    ]
    subprocess.run(command)

def main():
    while True:
        print("Kafka Command Menu:")
        print("1. Create Topic")
        print("2. List Topics")
        print("3. Delete Topic")
        print("4. Describe Topic")
        print("5. List Consumer Groups")
        print("6. Describe Consumer Group")
        print("7. Exit")
        choice = input("Enter your choice: ")

        if choice == '1':
            topic_name = input("Enter topic name: ")
            partitions = input("Enter number of partitions (default 1): ") or 1
            replication_factor = input("Enter replication factor (default 1): ") or 1
            create_topic(topic_name, int(partitions), int(replication_factor))
        elif choice == '2':
            list_topics()
        elif choice == '3':
            topic_name = input("Enter topic name: ")
            delete_topic(topic_name)
        elif choice == '4':
            topic_name = input("Enter topic name: ")
            describe_topic(topic_name)
        elif choice == '5':
            list_consumer_groups()
        elif choice == '6':
            group_id = input("Enter consumer group ID: ")
            describe_consumer_group(group_id)
        elif choice == '7':
            break
        else:
            print("Invalid choice. Please try again.")

if __name__ == "__main__":
    main()