"""
Helper module to add necessary paths to sys.path to make imports work.
This is a minimal solution to let Robot Framework import the provider modules directly.
"""

import sys
import pathlib

# Add the project root to sys.path to make imports work
root_dir = pathlib.Path(__file__).parent.parent.parent
web_dir = pathlib.Path(__file__).parent.parent
test_data_dir = pathlib.Path(__file__).parent

# Make both the root and web directories available for imports
for path in [str(root_dir), str(web_dir), str(test_data_dir)]:
    if path not in sys.path:
        sys.path.insert(0, path)


# This function does nothing - it's just here so Robot Framework
# will import this module and execute the path setup code above
def init_paths():
    """Initialize paths to make imports work. Not meant to be called directly."""
    pass
