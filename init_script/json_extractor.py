from dataclasses import dataclass
import json
import os

@dataclass
class JsonExtractor:
    """
    A class to extract JSON data from a file.

    Attributes:
        file (str): The path to the JSON file.
        absolute_path (bool): If True, `file` is treated as an absolute path. If False,
            it is treated as a path relative to the current working directory.
    """

    def __init__(self, file: str, absolute_path=False):
        """
        Initializes the JsonExtractor with the given file path.

        Args:
            file (str): The path to the JSON file.
            absolute_path (bool, optional): If True, `file` is treated as an absolute path.
                If False, it is treated as a path relative to the current working directory.
                Defaults to False.
        """
        if absolute_path:
            self._file: str = file
        else:
            self._file: str = f"{os.getcwd()}/{file}"

    def extract(self) -> dict:
        """
        Extracts JSON data from the file and returns it as a dictionary.

        Returns:
            dict: The extracted JSON data as a dictionary.
        """
        with open(self._file, 'r') as f:
            return json.load(f)
