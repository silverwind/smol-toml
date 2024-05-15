#!/usr/bin/env bash
#
# Requires toml-test from https://github.com/toml-lang/toml-test, commit 78f8c61
# or newer (Oct 2023).

skip_decode=(
	# Invalid UTF-8 strings are not rejected
	-skip='invalid/encoding/bad-utf8-*'

	# Certain invalid UTF-8 codepoints are not rejected
	-skip='invalid/encoding/bad-codepoint'
	-skip='invalid/string/bad-uni-esc-6'

	# JS doesn't reject invalid dates, but interprets extra days such as "Feb 30" as "Feb 28 +2d" gracefully
	# This behavior is implementation specific, although this should hold true for all major JS engines out there.
	# See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/parse#non-standard_date_strings
	#
	# While smol-toml could implement additional checks, this has not been done for performance reasons
	-skip='invalid/local-date/feb-29'
	-skip='invalid/local-datetime/feb-29'
	-skip='invalid/datetime/feb-29'
	-skip='invalid/local-date/feb-30'
	-skip='invalid/local-datetime/feb-30'
	-skip='invalid/datetime/feb-30'

	# https://github.com/toml-lang/toml-test/issues/154
	-skip='valid/integer/long'
)

skip_encode=(
	# https://github.com/toml-lang/toml-test/issues/155
	-skip='valid/spec/offset-date-time-0'
	-skip='valid/spec/local-date-time-0'
	-skip='valid/spec/local-time-0'

	# Some more Float <> Integer shenanigans
	-skip='valid/inline-table/spaces'
	-skip='valid/float/zero'
	-skip='valid/float/underscore'
	-skip='valid/float/exponent'
	-skip='valid/comment/tricky'
	-skip='valid/spec/float-0'

	# https://github.com/toml-lang/toml-test/issues/154
	-skip='valid/integer/long'
)

e=0
# -int-as-float as there is no way to distinguish between them at this time.
# For the encoder, distinction is made between floats and integers using JS bigint, however
# due to the lack of option to always serialize plain numbers as floats, some tests fail (and are therefore skipped)
~/go/bin/toml-test -int-as-float          ${skip_decode[@]} ./toml-test-parse.mjs  || e=1
~/go/bin/toml-test               -encoder ${skip_encode[@]} ./toml-test-encode.mjs || e=1
exit $e
