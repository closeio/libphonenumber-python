#include <cstdint>
#include <functional>
#include <list>
#include <memory>
#include <optional>
#include <sstream>
#include <string>

#include <pybind11/pybind11.h>
#include <pybind11/stl.h>
#include <unicode/locid.h>

#include "phonenumbers/geocoding/phonenumber_offline_geocoder.h"
#include "phonenumbers/phonenumber.pb.h"
#include "phonenumbers/phonenumbermatch.h"
#include "phonenumbers/phonenumbermatcher.h"
#include "phonenumbers/phonenumberutil.h"

namespace py = pybind11;

namespace {

using i18n::phonenumbers::PhoneNumber;
using i18n::phonenumbers::PhoneNumberMatch;
using i18n::phonenumbers::PhoneNumberMatcher;
using i18n::phonenumbers::PhoneNumberOfflineGeocoder;
using i18n::phonenumbers::PhoneNumberUtil;

constexpr int kPythonUnknownPhoneNumberType = 99;

const PhoneNumberUtil& phone_util() {
  return *PhoneNumberUtil::GetInstance();
}

PhoneNumberUtil::PhoneNumberType to_native_number_type(int value) {
  if (value == kPythonUnknownPhoneNumberType) {
    return PhoneNumberUtil::UNKNOWN;
  }
  return static_cast<PhoneNumberUtil::PhoneNumberType>(value);
}

int to_python_number_type(PhoneNumberUtil::PhoneNumberType value) {
  if (value == PhoneNumberUtil::UNKNOWN) {
    return kPythonUnknownPhoneNumberType;
  }
  return static_cast<int>(value);
}

icu::Locale make_locale(
    const std::string& language,
    const std::optional<std::string>& script,
    const std::optional<std::string>& region) {
  std::string locale_name = language;
  if (script && !script->empty()) {
    locale_name += "_" + *script;
  }
  if (region && !region->empty()) {
    locale_name += "_" + *region;
  }
  return icu::Locale::createFromName(locale_name.c_str());
}

template <typename Value>
py::object optional_value(bool present, Value value) {
  if (!present) {
    return py::none();
  }
  return py::cast(value);
}

bool phone_numbers_equal(
    const PhoneNumber& first, const PhoneNumber& second) {
  if (first.has_country_code() != second.has_country_code() ||
      (first.has_country_code() &&
       first.country_code() != second.country_code())) {
    return false;
  }
  if (first.has_national_number() != second.has_national_number() ||
      (first.has_national_number() &&
       first.national_number() != second.national_number())) {
    return false;
  }
  if (first.has_extension() != second.has_extension() ||
      (first.has_extension() && first.extension() != second.extension())) {
    return false;
  }
  // The Python implementation treats unset and explicit false as equal.
  if (first.italian_leading_zero() != second.italian_leading_zero()) {
    return false;
  }
  if (first.has_number_of_leading_zeros() !=
          second.has_number_of_leading_zeros() ||
      (first.has_number_of_leading_zeros() &&
       first.number_of_leading_zeros() !=
           second.number_of_leading_zeros())) {
    return false;
  }
  if (first.has_raw_input() != second.has_raw_input() ||
      (first.has_raw_input() && first.raw_input() != second.raw_input())) {
    return false;
  }
  if (first.country_code_source() != second.country_code_source()) {
    return false;
  }
  return (
      first.has_preferred_domestic_carrier_code() ==
          second.has_preferred_domestic_carrier_code() &&
      (!first.has_preferred_domestic_carrier_code() ||
       first.preferred_domestic_carrier_code() ==
           second.preferred_domestic_carrier_code()));
}

std::string phone_number_repr(const PhoneNumber& number) {
  py::object country_code = optional_value(
      number.has_country_code(), number.country_code());
  py::object national_number = optional_value(
      number.has_national_number(), number.national_number());
  py::object extension = optional_value(
      number.has_extension(), number.extension());
  py::object italian_leading_zero = optional_value(
      number.has_italian_leading_zero(), number.italian_leading_zero());
  py::object number_of_leading_zeros = optional_value(
      number.has_number_of_leading_zeros(),
      number.number_of_leading_zeros());
  py::object preferred_domestic_carrier_code = optional_value(
      number.has_preferred_domestic_carrier_code(),
      number.preferred_domestic_carrier_code());

  return py::str(
             "PhoneNumber(country_code={}, national_number={}, extension={!r}, "
             "italian_leading_zero={}, number_of_leading_zeros={}, "
             "country_code_source={}, "
             "preferred_domestic_carrier_code={!r})")
      .attr("format")(
          country_code,
          national_number,
          extension,
          italian_leading_zero,
          number_of_leading_zeros,
          static_cast<int>(number.country_code_source()),
          preferred_domestic_carrier_code)
      .cast<std::string>();
}

std::string phone_number_str(const PhoneNumber& number) {
  std::ostringstream output;
  output << "Country Code: ";
  if (number.has_country_code()) {
    output << number.country_code();
  } else {
    output << "None";
  }
  output << " National Number: ";
  if (number.has_national_number()) {
    output << number.national_number();
  } else {
    output << "None";
  }
  if (number.has_italian_leading_zero()) {
    output << " Leading Zero(s): "
           << (number.italian_leading_zero() ? "True" : "False");
  }
  if (number.has_number_of_leading_zeros()) {
    output << " Number of leading zeros: "
           << number.number_of_leading_zeros();
  }
  if (number.has_extension()) {
    output << " Extension: " << number.extension();
  }
  if (number.country_code_source() !=
      i18n::phonenumbers::PhoneNumber_CountryCodeSource_UNSPECIFIED) {
    output << " Country Code Source: "
           << static_cast<int>(number.country_code_source());
  }
  if (number.has_preferred_domestic_carrier_code()) {
    output << " Preferred Domestic Carrier Code: "
           << number.preferred_domestic_carrier_code();
  }
  return output.str();
}

std::pair<int, PhoneNumber> parse_number(
    const std::string& value,
    const std::optional<std::string>& region,
    bool keep_raw_input) {
  PhoneNumber number;
  const std::string default_region = region.value_or("");
  PhoneNumberUtil::ErrorType error;
  if (keep_raw_input) {
    error = phone_util().ParseAndKeepRawInput(
        value, default_region, &number);
  } else {
    error = phone_util().Parse(value, default_region, &number);
  }
  return {static_cast<int>(error), number};
}

std::string format_number(const PhoneNumber& number, int format) {
  std::string result;
  phone_util().Format(
      number,
      static_cast<PhoneNumberUtil::PhoneNumberFormat>(format),
      &result);
  return result;
}

std::optional<std::string> region_code_for_number(
    const PhoneNumber& number) {
  std::string region;
  phone_util().GetRegionCodeForNumber(number, &region);
  if (region.empty() || region == "ZZ") {
    return std::nullopt;
  }
  return region;
}

std::string region_code_for_country_code(int country_code) {
  std::string region;
  phone_util().GetRegionCodeForCountryCode(country_code, &region);
  return region;
}

std::string national_significant_number(const PhoneNumber& number) {
  std::string result;
  phone_util().GetNationalSignificantNumber(number, &result);
  return result;
}

py::list find_numbers(
    const std::string& text,
    const std::optional<std::string>& region,
    int leniency,
    int max_tries) {
  PhoneNumberMatcher matcher(
      phone_util(),
      text,
      region.value_or(""),
      static_cast<PhoneNumberMatcher::Leniency>(leniency),
      max_tries);
  py::list matches;
  while (matcher.HasNext()) {
    PhoneNumberMatch match;
    if (!matcher.Next(&match)) {
      break;
    }
    matches.append(py::make_tuple(
        match.start(), match.raw_string(), PhoneNumber(match.number())));
  }
  return matches;
}

PhoneNumberOfflineGeocoder& geocoder() {
  static PhoneNumberOfflineGeocoder instance;
  return instance;
}

std::string description_for_number(
    const PhoneNumber& number,
    const std::string& language,
    const std::optional<std::string>& script,
    const std::optional<std::string>& user_region,
    bool assume_valid) {
  const icu::Locale locale = make_locale(language, script, std::nullopt);
  if (assume_valid) {
    if (user_region) {
      return geocoder().GetDescriptionForValidNumber(
          number, locale, *user_region);
    }
    return geocoder().GetDescriptionForValidNumber(number, locale);
  }
  if (user_region) {
    return geocoder().GetDescriptionForNumber(number, locale, *user_region);
  }
  return geocoder().GetDescriptionForNumber(number, locale);
}

void set_optional_int(
    py::object value,
    const std::function<void(int)>& setter,
    const std::function<void()>& clearer) {
  if (value.is_none()) {
    clearer();
  } else {
    setter(value.cast<int>());
  }
}

void set_optional_uint64(
    py::object value,
    const std::function<void(std::uint64_t)>& setter,
    const std::function<void()>& clearer) {
  if (value.is_none()) {
    clearer();
  } else {
    setter(value.cast<std::uint64_t>());
  }
}

void set_optional_bool(
    py::object value,
    const std::function<void(bool)>& setter,
    const std::function<void()>& clearer) {
  if (value.is_none()) {
    clearer();
  } else {
    setter(value.cast<bool>());
  }
}

void set_optional_string(
    py::object value,
    const std::function<void(const std::string&)>& setter,
    const std::function<void()>& clearer) {
  if (value.is_none()) {
    clearer();
  } else {
    setter(value.cast<std::string>());
  }
}

}  // namespace

PYBIND11_MODULE(_native, module) {
  module.doc() = "Native bindings to Google's C++ libphonenumber";
  module.attr("LIBPHONENUMBER_VERSION") = LIBPHONENUMBER_VERSION;

  py::class_<PhoneNumber>(module, "PhoneNumber")
      .def(
          py::init([](
                       py::object country_code,
                       py::object national_number,
                       py::object extension,
                       py::object italian_leading_zero,
                       py::object number_of_leading_zeros,
                       py::object raw_input,
                       int country_code_source,
                       py::object preferred_domestic_carrier_code) {
            PhoneNumber number;
            if (!country_code.is_none()) {
              number.set_country_code(country_code.cast<int>());
            }
            if (!national_number.is_none()) {
              number.set_national_number(
                  national_number.cast<std::uint64_t>());
            }
            if (!extension.is_none()) {
              number.set_extension(extension.cast<std::string>());
            }
            if (!italian_leading_zero.is_none()) {
              number.set_italian_leading_zero(
                  italian_leading_zero.cast<bool>());
            }
            if (!number_of_leading_zeros.is_none()) {
              number.set_number_of_leading_zeros(
                  number_of_leading_zeros.cast<int>());
            }
            if (!raw_input.is_none()) {
              number.set_raw_input(raw_input.cast<std::string>());
            }
            if (country_code_source != 0) {
              number.set_country_code_source(
                  static_cast<
                      i18n::phonenumbers::PhoneNumber_CountryCodeSource>(
                      country_code_source));
            }
            if (!preferred_domestic_carrier_code.is_none()) {
              number.set_preferred_domestic_carrier_code(
                  preferred_domestic_carrier_code.cast<std::string>());
            }
            return number;
          }),
          py::arg("country_code") = py::none(),
          py::arg("national_number") = py::none(),
          py::arg("extension") = py::none(),
          py::arg("italian_leading_zero") = py::none(),
          py::arg("number_of_leading_zeros") = py::none(),
          py::arg("raw_input") = py::none(),
          py::arg("country_code_source") = 0,
          py::arg("preferred_domestic_carrier_code") = py::none())
      .def_property(
          "country_code",
          [](const PhoneNumber& number) {
            return optional_value(
                number.has_country_code(), number.country_code());
          },
          [](PhoneNumber& number, py::object value) {
            set_optional_int(
                value,
                [&number](int item) { number.set_country_code(item); },
                [&number]() { number.clear_country_code(); });
          })
      .def_property(
          "national_number",
          [](const PhoneNumber& number) {
            return optional_value(
                number.has_national_number(), number.national_number());
          },
          [](PhoneNumber& number, py::object value) {
            set_optional_uint64(
                value,
                [&number](std::uint64_t item) {
                  number.set_national_number(item);
                },
                [&number]() { number.clear_national_number(); });
          })
      .def_property(
          "extension",
          [](const PhoneNumber& number) {
            return optional_value(
                number.has_extension(), number.extension());
          },
          [](PhoneNumber& number, py::object value) {
            set_optional_string(
                value,
                [&number](const std::string& item) {
                  number.set_extension(item);
                },
                [&number]() { number.clear_extension(); });
          })
      .def_property(
          "italian_leading_zero",
          [](const PhoneNumber& number) {
            return optional_value(
                number.has_italian_leading_zero(),
                number.italian_leading_zero());
          },
          [](PhoneNumber& number, py::object value) {
            set_optional_bool(
                value,
                [&number](bool item) {
                  number.set_italian_leading_zero(item);
                },
                [&number]() { number.clear_italian_leading_zero(); });
          })
      .def_property(
          "number_of_leading_zeros",
          [](const PhoneNumber& number) {
            return optional_value(
                number.has_number_of_leading_zeros(),
                number.number_of_leading_zeros());
          },
          [](PhoneNumber& number, py::object value) {
            set_optional_int(
                value,
                [&number](int item) {
                  number.set_number_of_leading_zeros(item);
                },
                [&number]() { number.clear_number_of_leading_zeros(); });
          })
      .def_property(
          "raw_input",
          [](const PhoneNumber& number) {
            return optional_value(
                number.has_raw_input(), number.raw_input());
          },
          [](PhoneNumber& number, py::object value) {
            set_optional_string(
                value,
                [&number](const std::string& item) {
                  number.set_raw_input(item);
                },
                [&number]() { number.clear_raw_input(); });
          })
      .def_property(
          "country_code_source",
          [](const PhoneNumber& number) {
            return static_cast<int>(number.country_code_source());
          },
          [](PhoneNumber& number, int value) {
            number.set_country_code_source(
                static_cast<i18n::phonenumbers::PhoneNumber_CountryCodeSource>(
                    value));
          })
      .def_property(
          "preferred_domestic_carrier_code",
          [](const PhoneNumber& number) {
            return optional_value(
                number.has_preferred_domestic_carrier_code(),
                number.preferred_domestic_carrier_code());
          },
          [](PhoneNumber& number, py::object value) {
            set_optional_string(
                value,
                [&number](const std::string& item) {
                  number.set_preferred_domestic_carrier_code(item);
                },
                [&number]() {
                  number.clear_preferred_domestic_carrier_code();
                });
          })
      .def("__repr__", &phone_number_repr)
      .def("__str__", &phone_number_str)
      .def(
          "__eq__",
          &phone_numbers_equal,
          py::is_operator());

  module.def(
      "parse", &parse_number, py::arg("value"), py::arg("region") = py::none(),
      py::arg("keep_raw_input") = false);
  module.def("format_number", &format_number);
  module.def(
      "is_possible_number",
      [](const PhoneNumber& number) {
        return phone_util().IsPossibleNumber(number);
      });
  module.def(
      "is_valid_number",
      [](const PhoneNumber& number) {
        return phone_util().IsValidNumber(number);
      });
  module.def(
      "is_valid_number_for_region",
      [](const PhoneNumber& number, const std::string& region) {
        return phone_util().IsValidNumberForRegion(number, region);
      });
  module.def(
      "number_type",
      [](const PhoneNumber& number) {
        return to_python_number_type(phone_util().GetNumberType(number));
      });
  module.def(
      "is_number_type_geographical",
      [](int number_type, int country_code) {
        return phone_util().IsNumberGeographical(
            to_native_number_type(number_type), country_code);
      });
  module.def("region_code_for_number", &region_code_for_number);
  module.def(
      "country_code_for_region",
      [](const std::optional<std::string>& region) {
        if (!region) {
          return 0;
        }
        return phone_util().GetCountryCodeForRegion(*region);
      });
  module.def(
      "region_code_for_country_code", &region_code_for_country_code);
  module.def(
      "region_codes_for_country_code",
      [](int country_code) {
        std::list<std::string> regions;
        phone_util().GetRegionCodesForCountryCallingCode(
            country_code, &regions);
        return regions;
      });
  module.def(
      "national_significant_number", &national_significant_number);
  module.def(
      "find_numbers",
      &find_numbers,
      py::arg("text"),
      py::arg("region") = py::none(),
      py::arg("leniency") = 1,
      py::arg("max_tries") = 65535);
  module.def(
      "description_for_number",
      &description_for_number,
      py::arg("number"),
      py::arg("language"),
      py::arg("script") = py::none(),
      py::arg("region") = py::none(),
      py::arg("assume_valid") = false);
}
