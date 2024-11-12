import argparse


class LatencyCalculator:
    def __init__(self):
        # Lists to store packet details (size, timestamp) and calculated latencies
        self.pub_to_relay = []
        self.relay_to_sub = []
        self.latencies = []

    def register_pub_to_relay(self, size, timestamp):
        """
        Store Publisher to Relay packet details.
        """
        self.pub_to_relay.append((size, timestamp))

    def register_relay_to_sub(self, size, timestamp):
        """
        Store Relay to Subscriber packet details.
        """
        self.relay_to_sub.append((size, timestamp))

    def calculate_latencies(self):
        """
        Calculate latencies for matching Publisher → Relay and Relay → Subscriber packets.
        """
        pub_idx = 0

        for relay_size, relay_timestamp in self.relay_to_sub:
            while pub_idx < len(self.pub_to_relay):

                pub_size, pub_timestamp = self.pub_to_relay[pub_idx]

                # If Publisher → Relay timestamp is less than Relay → Subscriber timestamp, proceed with comparison
                if pub_timestamp < relay_timestamp:
                    if pub_size == relay_size:
                        # If sizes match, calculate latency and pop both packets
                        latency = relay_timestamp - pub_timestamp
                        self.latencies.append(latency)

                        for i in range(0, pub_idx + 1):
                            # Remove the matched and previously compared Publisher → Relay packets
                            self.pub_to_relay.pop(0)
                        break  # Move to the next Relay → Subscriber packet after matching

                    else:
                        # If packet sizes don't match, just move to the next Publisher → Relay packet
                        pub_idx += 1

                else:
                    # If Publisher → Relay timestamp is greater than or equal to Relay → Subscriber timestamp, move to next Relay → Subscriber packet
                    break

    def calculate_average_latency(self):
        """
        Return the average latency.
        """
        if len(self.latencies) > 0:
            return sum(self.latencies) / len(self.latencies)

        else:
            return 0  # No valid latencies


def parse_capture_data_from_file(file_path):
    """
    Parse the capture data from a text file and register Publisher → Relay and Relay → Subscriber packets.
    """
    latency_calculator = LatencyCalculator()

    with open(file_path, "r") as file:
        for line in file:
            parts = line.split()  # Split the line by whitespace

            if len(parts) < 11:
                continue  # Skip lines that don't have the correct format

            if "ARP" in line:
                continue  # Skip ARP packets

            timestamp = float(parts[1])
            src_ip = parts[2]
            dst_ip = parts[4]

            packet_length_field = parts[10]  # This will be something like "Len=537"
            packet_size = int(packet_length_field.split("=")[1])

            # print(f"Packet size: {packet_size}, Timestamp: {timestamp}, Packet Size: {packet_size}, Source: {src_ip}, Destination: {dst_ip}")

            if src_ip == "172.18.0.4" and dst_ip == "172.18.0.2":
                # Publisher → Relay
                latency_calculator.register_pub_to_relay(packet_size, timestamp)

            elif src_ip == "172.18.0.2" and dst_ip == "172.18.0.3":
                # Relay → Subscriber
                latency_calculator.register_relay_to_sub(packet_size, timestamp)

    return latency_calculator


def main():
    # Set up argument parsing
    parser = argparse.ArgumentParser(
        description="Calculate one-way latency from capture data"
    )
    parser.add_argument("file_path", help="Path to the capture data file")
    args = parser.parse_args()

    # Parse the capture data and calculate latencies
    latency_calculator = parse_capture_data_from_file(args.file_path)
    # print(len(latency_calculator.relay_to_sub))
    latency_calculator.calculate_latencies()

    # Calculate and print the average latency
    avg_latency = latency_calculator.calculate_average_latency()

    print(f"Average one-way latency: {avg_latency * 1000:.2f} ms")  # In milliseconds


if __name__ == "__main__":
    main()
