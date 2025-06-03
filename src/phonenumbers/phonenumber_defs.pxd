from libcpp cimport bool
from libcpp.string cimport string
from libcpp.map cimport map
from libcpp.vector cimport vector
from libcpp.set cimport set as cppset
from libcpp.list cimport list as cpplist
from libc.stdint cimport uint64_t, int32_t

cdef extern from "phonenumbers/phonenumber.pb.h" namespace "i18n::phonenumbers":
    cdef cppclass PhoneNumber:
        PhoneNumber()
        int country_code()
        void set_country_code(int value)
        uint64_t national_number()
        void set_national_number(uint64_t value)
        string extension()
        void set_extension(string value)
        bool has_italian_leading_zero()
        bool italian_leading_zero()
        void set_italian_leading_zero(bool value)
        bool has_number_of_leading_zeros()
        int number_of_leading_zeros()
        void set_number_of_leading_zeros(int value)
        bool has_raw_input()
        string raw_input()
        void set_raw_input(string value)
        bool has_country_code_source()
        CppCountryCodeSource country_code_source()
        void set_country_code_source(CppCountryCodeSource value)
        bool has_preferred_domestic_carrier_code()
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
    
    # Parse error types
    cdef enum CppErrorType "i18n::phonenumbers::PhoneNumberUtil::ErrorType":
        ERROR_NO_ERROR "i18n::phonenumbers::PhoneNumberUtil::NO_PARSING_ERROR" = 0
        ERROR_INVALID_COUNTRY_CODE "i18n::phonenumbers::PhoneNumberUtil::INVALID_COUNTRY_CODE" = 1
        ERROR_NOT_A_NUMBER "i18n::phonenumbers::PhoneNumberUtil::NOT_A_NUMBER" = 2
        ERROR_TOO_SHORT_AFTER_IDD "i18n::phonenumbers::PhoneNumberUtil::TOO_SHORT_AFTER_IDD" = 3
        ERROR_TOO_SHORT_NSN "i18n::phonenumbers::PhoneNumberUtil::TOO_SHORT_NSN" = 4
        ERROR_TOO_LONG "i18n::phonenumbers::PhoneNumberUtil::TOO_LONG" = 5

    # Country code source
    cdef enum CppCountryCodeSource "i18n::phonenumbers::PhoneNumber_CountryCodeSource":
        SOURCE_UNSPECIFIED "i18n::phonenumbers::PhoneNumber_CountryCodeSource_UNSPECIFIED" = 0
        SOURCE_FROM_NUMBER_WITH_PLUS_SIGN "i18n::phonenumbers::PhoneNumber_CountryCodeSource_FROM_NUMBER_WITH_PLUS_SIGN" = 1
        SOURCE_FROM_NUMBER_WITH_IDD "i18n::phonenumbers::PhoneNumber_CountryCodeSource_FROM_NUMBER_WITH_IDD" = 5
        SOURCE_FROM_NUMBER_WITHOUT_PLUS_SIGN "i18n::phonenumbers::PhoneNumber_CountryCodeSource_FROM_NUMBER_WITHOUT_PLUS_SIGN" = 10
        SOURCE_FROM_DEFAULT_COUNTRY "i18n::phonenumbers::PhoneNumber_CountryCodeSource_FROM_DEFAULT_COUNTRY" = 20

    # Match type for phone number comparison
    cdef enum CppMatchType "i18n::phonenumbers::PhoneNumberUtil::MatchType":
        MATCH_INVALID_NUMBER "i18n::phonenumbers::PhoneNumberUtil::INVALID_NUMBER" = 0
        MATCH_NO_MATCH "i18n::phonenumbers::PhoneNumberUtil::NO_MATCH" = 1
        MATCH_SHORT_NSN_MATCH "i18n::phonenumbers::PhoneNumberUtil::SHORT_NSN_MATCH" = 2
        MATCH_NSN_MATCH "i18n::phonenumbers::PhoneNumberUtil::NSN_MATCH" = 3
        MATCH_EXACT_MATCH "i18n::phonenumbers::PhoneNumberUtil::EXACT_MATCH" = 4

cdef extern from "phonenumbers/phonemetadata.pb.h" namespace "i18n::phonenumbers":
    cdef cppclass NumberFormat:
        NumberFormat()
        
        # Pattern and format
        bool has_pattern()
        string pattern()
        void set_pattern(const string& value)
        
        bool has_format()
        string format()
        void set_format(const string& value)
        
        # Leading digits patterns
        int leading_digits_pattern_size()
        string leading_digits_pattern(int index)
        void add_leading_digits_pattern(const string& value)
        
        # Formatting rules
        bool has_national_prefix_formatting_rule()
        string national_prefix_formatting_rule()
        void set_national_prefix_formatting_rule(const string& value)
        
        bool has_domestic_carrier_code_formatting_rule()
        string domestic_carrier_code_formatting_rule()
        void set_domestic_carrier_code_formatting_rule(const string& value)
        
        bool has_national_prefix_optional_when_formatting()
        bool national_prefix_optional_when_formatting()
        void set_national_prefix_optional_when_formatting(bool value)

    cdef cppclass PhoneNumberDesc:
        PhoneNumberDesc()
        
        # Pattern and example
        bool has_national_number_pattern()
        string national_number_pattern()
        void set_national_number_pattern(const string& value)
        
        bool has_example_number()
        string example_number()
        void set_example_number(const string& value)
        
        # Possible lengths
        int possible_length_size()
        int32_t possible_length(int index)
        void add_possible_length(int32_t value)
        
        int possible_length_local_only_size()
        int32_t possible_length_local_only(int index)
        void add_possible_length_local_only(int32_t value)


cdef extern from "phonenumbers/phonenumberutil.h" namespace "i18n::phonenumbers":
    cdef cppclass PhoneNumberUtil:
        @staticmethod
        PhoneNumberUtil* GetInstance()
        
        void Format(const PhoneNumber &number, CppPhoneNumberFormat numberFormat, string* formatted_number) const
        bool IsValidNumber(const PhoneNumber &number) const
        bool IsValidNumberForRegion(const PhoneNumber &number, const string &regionCode) const
        CppErrorType Parse(const string &numberToParse, const string &defaultRegion, PhoneNumber *phoneNumber) const
        CppPhoneNumberType GetNumberType(const PhoneNumber &number) const
        void GetRegionCodeForNumber(const PhoneNumber &number, string *region) const
        bool GetExampleNumber(const string &regionCode, PhoneNumber *number) const
        bool GetExampleNumberForType(const string &regionCode, CppPhoneNumberType type, PhoneNumber *number) const
        void FormatInOriginalFormat(const PhoneNumber &number, const string &regionCallingFrom, string *formattedNumber) const
        void FormatOutOfCountryCallingNumber(const PhoneNumber &number, const string &regionCallingFrom, string *formattedNumber) const
        void GetNationalSignificantNumber(const PhoneNumber &number, string *nationalNumber) const
        CppValidationResult IsPossibleNumberWithReason(const PhoneNumber &number) const
        bool TruncateTooLongNumber(PhoneNumber *number) const
        
        # Public metadata-related methods
        void GetSupportedRegions(cppset[string]* regions) const
        void GetSupportedGlobalNetworkCallingCodes(cppset[int]* calling_codes) const
        void GetSupportedCallingCodes(cppset[int]* calling_codes) const
        void GetSupportedTypesForRegion(const string& region_code, cppset[CppPhoneNumberType]* types) const
        
        # Region code methods
        void GetRegionCodeForCountryCode(int country_code, string* region_code) const
        void GetRegionCodesForCountryCallingCode(int country_calling_code, cpplist[string]* region_codes) const
        
        # Match type methods
        CppMatchType IsNumberMatch(const PhoneNumber& first_number, const PhoneNumber& second_number) const
        CppMatchType IsNumberMatchWithTwoStrings(const string& first_number, const string& second_number) const
        CppMatchType IsNumberMatchWithOneString(const PhoneNumber& first_number, const string& second_number) const