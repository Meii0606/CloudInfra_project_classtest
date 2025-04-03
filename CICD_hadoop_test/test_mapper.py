import io
import sys
import unittest
from unittest.mock import patch
import mapper  # Import the entire module since it doesn't have functions to import

class TestMapper(unittest.TestCase):
    
    @patch('sys.stdin', io.StringIO("hello world\nworld hello\n"))
    @patch('sys.stdout', new_callable=io.StringIO)
    def test_main_functionality(self, mock_stdout):
        # Save the original __name__ value
        original_name = mapper.__name__
        
        # Set __name__ to "__main__" to trigger the loop
        mapper.__name__ = "__main__"
        
        # Re-import to execute the script
        import importlib
        importlib.reload(mapper)
        
        # Reset __name__ to its original value
        mapper.__name__ = original_name
        
        # Check the output
        expected_output = "hello\t1\nworld\t1\nworld\t1\nhello\t1\n"
        self.assertEqual(mock_stdout.getvalue(), expected_output)
    
    @patch('sys.stdin', io.StringIO(""))
    @patch('sys.stdout', new_callable=io.StringIO)
    def test_empty_input(self, mock_stdout):
        # Save the original __name__ value
        original_name = mapper.__name__
        
        # Set __name__ to "__main__" to trigger the loop
        mapper.__name__ = "__main__"
        
        # Re-import to execute the script
        import importlib
        importlib.reload(mapper)
        
        # Reset __name__ to its original value
        mapper.__name__ = original_name
        
        # Check the output (should be empty)
        self.assertEqual(mock_stdout.getvalue(), "")
    
    @patch('sys.stdin', io.StringIO("word1 word2\n  word3  word4  \n"))
    @patch('sys.stdout', new_callable=io.StringIO)
    def test_whitespace_handling(self, mock_stdout):
        # Save the original __name__ value
        original_name = mapper.__name__
        
        # Set __name__ to "__main__" to trigger the loop
        mapper.__name__ = "__main__"
        
        # Re-import to execute the script
        import importlib
        importlib.reload(mapper)
        
        # Reset __name__ to its original value
        mapper.__name__ = original_name
        
        # Check the output
        expected_output = "word1\t1\nword2\t1\nword3\t1\nword4\t1\n"
        self.assertEqual(mock_stdout.getvalue(), expected_output)

if __name__ == "__main__":
    unittest.main()
