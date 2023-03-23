import json
import os
import sys

import charset_normalizer

def get_encoding(directory_path):
    # Loop through all files in the directory
    file_encodings = {}
    for filename in os.listdir(directory_path):
        filepath = os.path.join(directory_path, filename)
        if os.path.isfile(filepath):
            # Use charset_normalizer library to detect the encoding of the file
            with open(filepath, 'rb') as f:
                result = charset_normalizer.detect(f.read())
                encoding = result['encoding']
                file_encodings[os.path.abspath(filepath)] = encoding
        else:
            file_encodings = {**file_encodings, **(get_encoding(filepath) or {})}
    return file_encodings

if __name__ == '__main__':
    directory_path = sys.argv[1]
    encodings = get_encoding(directory_path)
    print(json.dumps(encodings, indent=4))
