import unittest
import json
import os
from json_extractor import JsonExtractor

class TestJsonExtractor(unittest.TestCase):

    def setUp(self):
        # Create a temporary JSON file for testing
        self.test_data = {
            "name": "Alice",
            "age": 30,
            "city": "New York"
        }
        self.test_file = "test_data.json"
        with open(self.test_file, 'w') as f:
            json.dump(self.test_data, f)

    def tearDown(self):
        # Remove the temporary JSON file after testing
        os.remove(self.test_file)

    def test_extract_absolute_path(self):
        extractor = JsonExtractor(self.test_file, absolute_path=True)
        extracted_data = extractor.extract()
        self.assertEqual(extracted_data, self.test_data)

    def test_extract_relative_path(self):
        extractor = JsonExtractor(self.test_file)
        extracted_data = extractor.extract()
        self.assertEqual(extracted_data, self.test_data)

if __name__ == '__main__':
    unittest.main()
