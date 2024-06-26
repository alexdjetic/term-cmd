import socket

class NetworkInfo:

    def __init__(self):
        self._privip = self.get_privip()

    def get_privip(self):
        try:
            self._nom = socket.gethostname()
            privip = socket.gethostbyname(self._nom)
            return privip
        except Exception as e:
            return str(e)

    @property
    def nom(self):
        """The nom property."""
        return self._nom
    @nom.setter
    def nom(self, value: str):
        self._nom = value

    @property
    def privip(self):
        """The privip property."""
        return self._privip
    @privip.setter
    def privip(self, value: str):
        self._privip = value

if __name__ == "__main__":
    network_info: NetworkInfo = NetworkInfo()
    print(f"{network_info.privip}")