"""
Prefix-based phone number description functionality.

This module provides functions to get descriptions for phone numbers based on
prefix matching with localization support.
"""

from .. import format_number, PhoneNumberFormat

# Constants
U_PLUS = "+"
U_EMPTY_STRING = ""

# Locale normalization for Chinese variants
_LOCALE_NORMALIZATION_MAP = {
    'zh_Hant': 'zh_TW',
    'zh_Hans': 'zh_CN',
}


def _may_fall_back_to_english(lang):
    """Check if we may fall back to English for the given language."""
    # Allow fallback to English for most languages except Chinese variants
    return not (lang == 'zh' or lang.startswith('zh_'))


def _full_locale(lang, script, region):
    """Construct a full locale string from components."""
    if script is not None and region is not None:
        return "%s_%s_%s" % (lang, script, region)
    elif script is not None:
        return "%s_%s" % (lang, script)
    elif region is not None:
        return "%s_%s" % (lang, region)
    else:
        return lang


def _find_lang(langdict, lang, script=None, region=None):
    """Find the most appropriate language entry in langdict."""
    if not langdict:
        return None
    
    # Try exact match first
    full_locale = _full_locale(lang, script, region)
    if full_locale in langdict:
        return langdict[full_locale]
    
    # Try with normalized locale
    if full_locale in _LOCALE_NORMALIZATION_MAP:
        normalized = _LOCALE_NORMALIZATION_MAP[full_locale]
        if normalized in langdict:
            return langdict[normalized]
    
    # Try without region
    if region is not None:
        no_region_locale = _full_locale(lang, script, None)
        if no_region_locale in langdict:
            return langdict[no_region_locale]
    
    # Try without script
    if script is not None:
        no_script_locale = _full_locale(lang, None, region)
        if no_script_locale in langdict:
            return langdict[no_script_locale]
    
    # Try just language
    if lang in langdict:
        return langdict[lang]
    
    # Try English fallback if allowed
    if _may_fall_back_to_english(lang) and 'en' in langdict:
        return langdict['en']
    
    # Return any available entry as last resort
    if langdict:
        return next(iter(langdict.values()))
    
    return None


def _prefix_description_for_number(data, longest_prefix, numobj, lang, script=None, region=None):
    """Return a text description of a PhoneNumber for the given language.
    
    Args:
        data: Dictionary mapping prefixes to language dictionaries
        longest_prefix: Maximum prefix length to check
        numobj: PhoneNumber object to describe
        lang: Language code (e.g., 'en', 'fr', 'de')
        script: Optional script code (e.g., 'Latn', 'Cyrl')
        region: Optional region code (e.g., 'US', 'GB')
    
    Returns:
        str: Description of the phone number location, or empty string if unavailable.
    """
    e164_num = format_number(numobj, PhoneNumberFormat.E164)
    if not e164_num.startswith(U_PLUS):  # pragma no cover
        raise Exception("Expect E164 number to start with +")
    
    for prefix_len in range(longest_prefix, 0, -1):
        prefix = e164_num[1:(1 + prefix_len)]
        if prefix in data:
            name = _find_lang(data[prefix], lang, script, region)
            if name is not None:
                return name
            else:
                return U_EMPTY_STRING
    
    return U_EMPTY_STRING


__all__ = [
    '_prefix_description_for_number',
    '_find_lang',
    '_may_fall_back_to_english',
    '_full_locale'
]