from libcpp cimport bool
from libcpp.string cimport string
from libcpp.map cimport map
from libcpp.vector cimport vector
from libc.stdint cimport uint64_t

cdef extern from "phonenumbers/phonenumber.pb.h" namespace "i18n::phonenumbers":
    cdef cppclass PhoneNumber:
        PhoneNumber()
        int country_code()
        void set_country_code(int value)
        uint64_t national_number()
        void set_national_number(uint64_t value)
        string extension()
        void set_extension(string value)
        bool italian_leading_zero()
        void set_italian_leading_zero(bool value)
        int number_of_leading_zeros()
        void set_number_of_leading_zeros(int value)
        string raw_input()
        void set_raw_input(string value)
        CppCountryCodeSource country_code_source()
        void set_country_code_source(CppCountryCodeSource value)
        string preferred_domestic_carrier_code()
        void set_preferred_domestic_carrier_code(string value)

# Define our own enum constants that match the C++ ones
cdef extern from * namespace "":
    # Phone number formats
    cdef enum CppPhoneNumberFormat "i18n::phonenumbers::PhoneNumberUtil::PhoneNumberFormat":
        FORMAT_E164 "i18n::phonenumbers::PhoneNumberUtil::E164" = 0
        FORMAT_INTERNATIONAL "i18n::phonenumbers::PhoneNumberUtil::INTERNATIONAL" = 1
        FORMAT_NATIONAL "i18n::phonenumbers::PhoneNumberUtil::NATIONAL" = 2
        FORMAT_RFC3966 "i18n::phonenumbers::PhoneNumberUtil::RFC3966" = 3
    
    # Phone number types
    cdef enum CppPhoneNumberType "i18n::phonenumbers::PhoneNumberUtil::PhoneNumberType":
        TYPE_FIXED_LINE "i18n::phonenumbers::PhoneNumberUtil::FIXED_LINE" = 0
        TYPE_MOBILE "i18n::phonenumbers::PhoneNumberUtil::MOBILE" = 1
        TYPE_FIXED_LINE_OR_MOBILE "i18n::phonenumbers::PhoneNumberUtil::FIXED_LINE_OR_MOBILE" = 2
        TYPE_TOLL_FREE "i18n::phonenumbers::PhoneNumberUtil::TOLL_FREE" = 3
        TYPE_PREMIUM_RATE "i18n::phonenumbers::PhoneNumberUtil::PREMIUM_RATE" = 4
        TYPE_SHARED_COST "i18n::phonenumbers::PhoneNumberUtil::SHARED_COST" = 5
        TYPE_VOIP "i18n::phonenumbers::PhoneNumberUtil::VOIP" = 6
        TYPE_PERSONAL_NUMBER "i18n::phonenumbers::PhoneNumberUtil::PERSONAL_NUMBER" = 7
        TYPE_PAGER "i18n::phonenumbers::PhoneNumberUtil::PAGER" = 8
        TYPE_UAN "i18n::phonenumbers::PhoneNumberUtil::UAN" = 9
        TYPE_VOICEMAIL "i18n::phonenumbers::PhoneNumberUtil::VOICEMAIL" = 10
        TYPE_UNKNOWN "i18n::phonenumbers::PhoneNumberUtil::UNKNOWN" = 11
    
    # Validation results
    cdef enum CppValidationResult "i18n::phonenumbers::PhoneNumberUtil::ValidationResult":
        RESULT_IS_POSSIBLE "i18n::phonenumbers::PhoneNumberUtil::IS_POSSIBLE" = 0
        RESULT_IS_POSSIBLE_LOCAL_ONLY "i18n::phonenumbers::PhoneNumberUtil::IS_POSSIBLE_LOCAL_ONLY" = 1
        RESULT_INVALID_COUNTRY_CODE "i18n::phonenumbers::PhoneNumberUtil::INVALID_COUNTRY_CODE" = 2
        RESULT_TOO_SHORT "i18n::phonenumbers::PhoneNumberUtil::TOO_SHORT" = 3
        RESULT_INVALID_LENGTH "i18n::phonenumbers::PhoneNumberUtil::INVALID_LENGTH" = 4
        RESULT_TOO_LONG "i18n::phonenumbers::PhoneNumberUtil::TOO_LONG" = 5
    
    # Country code source
    cdef enum CppCountryCodeSource "i18n::phonenumbers::PhoneNumber_CountryCodeSource":
        SOURCE_UNSPECIFIED "i18n::phonenumbers::PhoneNumber_CountryCodeSource_UNSPECIFIED" = 0
        SOURCE_FROM_NUMBER_WITH_PLUS_SIGN "i18n::phonenumbers::PhoneNumber_CountryCodeSource_FROM_NUMBER_WITH_PLUS_SIGN" = 1
        SOURCE_FROM_NUMBER_WITH_IDD "i18n::phonenumbers::PhoneNumber_CountryCodeSource_FROM_NUMBER_WITH_IDD" = 5
        SOURCE_FROM_NUMBER_WITHOUT_PLUS_SIGN "i18n::phonenumbers::PhoneNumber_CountryCodeSource_FROM_NUMBER_WITHOUT_PLUS_SIGN" = 10
        SOURCE_FROM_DEFAULT_COUNTRY "i18n::phonenumbers::PhoneNumber_CountryCodeSource_FROM_DEFAULT_COUNTRY" = 20

cdef extern from "phonenumbers/phonenumberutil.h" namespace "i18n::phonenumbers":
    cdef cppclass PhoneNumberUtil:
        @staticmethod
        PhoneNumberUtil* GetInstance()
        
        void Format(const PhoneNumber &number, CppPhoneNumberFormat numberFormat, string* formatted_number) const
        bool IsValidNumber(const PhoneNumber &number) const
        bool IsValidNumberForRegion(const PhoneNumber &number, const string &regionCode) const
        bool Parse(const string &numberToParse, const string &defaultRegion, PhoneNumber *phoneNumber) const
        CppPhoneNumberType GetNumberType(const PhoneNumber &number) const
        void GetRegionCodeForNumber(const PhoneNumber &number, string *region) const
        bool GetExampleNumber(const string &regionCode, PhoneNumber *number) const
        bool GetExampleNumberForType(const string &regionCode, CppPhoneNumberType type, PhoneNumber *number) const
        void FormatInOriginalFormat(const PhoneNumber &number, const string &regionCallingFrom, string *formattedNumber) const
        void FormatOutOfCountryCallingNumber(const PhoneNumber &number, const string &regionCallingFrom, string *formattedNumber) const
        void GetNationalSignificantNumber(const PhoneNumber &number, string *nationalNumber) const
        CppValidationResult IsPossibleNumberWithReason(const PhoneNumber &number) const
        bool TruncateTooLongNumber(PhoneNumber *number) const