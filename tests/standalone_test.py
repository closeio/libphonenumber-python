import unittest
from phonenumber import (
    PhoneNumber,
    PhoneNumberUtil,
    PhoneNumberFormat,
    PhoneNumberType,
    parse,
    format_number,
    is_valid_number,
    get_number_type,
    get_example_number,
)


class TestPhoneNumber(unittest.TestCase):
    def test_parse_and_format(self):
        # Test parsing a US number
        phone = parse("+1 650 253 0000", "US")
        self.assertEqual(phone.country_code, 1)
        self.assertEqual(phone.national_number, 6502530000)
        
        # Test formatting
        self.assertEqual(format_number(phone, PhoneNumberFormat.E164), "+16502530000")
        self.assertEqual(format_number(phone, PhoneNumberFormat.INTERNATIONAL), "+1 650-253-0000")
        self.assertEqual(format_number(phone, PhoneNumberFormat.NATIONAL), "(650) 253-0000")
        self.assertEqual(format_number(phone, PhoneNumberFormat.RFC3966), "tel:+1-650-253-0000")
        
    def test_properties(self):
        # Test phone number properties
        phone = PhoneNumber()
        phone.country_code = 1
        phone.national_number = 6502530000
        phone.extension = "123"
        
        self.assertEqual(phone.country_code, 1)
        self.assertEqual(phone.national_number, 6502530000)
        self.assertEqual(phone.extension, "123")
        
        # Test repr and str
        self.assertEqual(repr(phone), "PhoneNumber(country_code=1, national_number=6502530000)")
        self.assertTrue(str(phone).startswith("+1 650-253-0000"))


if __name__ == "__main__":
    unittest.main()