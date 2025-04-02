import io
import sys
import unittest
from unittest.mock import patch
import reducer  # Import the entire module

class TestReducer(unittest.TestCase):
    
    @patch('sys.stdin', io.StringIO("apple\t1\napple\t1\nbanana\t1\norange\t1\norange\t1\n"))
    @patch('sys.stdout', new_callable=io.StringIO)
    def test_main_functionality(self, mock_stdout):
        # Save the original __name__ value
        original_name = reducer.__name__
        
        # Set __name__ to "__main__" to trigger the execution
        reducer.__name__ = "__main__"
        
        # Re-import to execute the script
        import importlib
        importlib.reload(reducer)
        
        # Reset __name__ to its original value
        reducer.__name__ = original_name
        
        # Check the output
        expected_output = "Modified: apple\t2\nModified: banana\t1\nModified: orange\t2\n"
        self.assertEqual(mock_stdout.getvalue(), expected_output)
    
    @patch('sys.stdin', io.StringIO("apple\t1\napple\tabc\napple\t1\n"))
    @patch('sys.stdout', new_callable=io.StringIO)
    def test_invalid_count(self, mock_stdout):
        # Save the original __name__ value
        original_name = reducer.__name__
        
        # Set __name__ to "__main__" to trigger the execution
        reducer.__name__ = "__main__"
        
        # Re-import to execute the script
        import importlib
        importlib.reload(reducer)
        
        # Reset __name__ to its original value
        reducer.__name__ = original_name
        
        # Check the output - the invalid count line should be skipped
        expected_output = "Modified: apple\t2\n"
        self.assertEqual(mock_stdout.getvalue(), expected_output)
    
    @patch('sys.stdin', io.StringIO(""))
    @patch('sys.stdout', new_callable=io.StringIO)
    def test_empty_input(self, mock_stdout):
        # Save the original __name__ value
        original_name = reducer.__name__
        
        # Set __name__ to "__main__" to trigger the execution
        reducer.__name__ = "__main__"
        
        # Re-import to execute the script
        import importlib
        importlib.reload(reducer)
        
        # Reset __name__ to its original value
        reducer.__name__ = original_name
        
        # Check the output - should be empty
        self.assertEqual(mock_stdout.getvalue(), "")

if __name__ == "__main__":
    unittest.main()
