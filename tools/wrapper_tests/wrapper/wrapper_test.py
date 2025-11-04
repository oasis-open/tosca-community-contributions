import os
import pytest

def test_wrapper_exists():
    """Test that wrapper.py exists in the expected location"""
    here = os.path.dirname(os.path.abspath(__file__))
    wrapper_path = here + '/../../../tools/wrappers/wrapper.py'
    assert os.path.isfile(wrapper_path), "wrapper.py file not found"