//////////////////////////////////////////////////////////////////////////////
//
// File: bacunits.h
//
// ECHELON MAKES NO REPRESENTATION, WARRANTY, OR CONDITION OF
// ANY KIND, EXPRESS, IMPLIED, STATUTORY, OR OTHERWISE OR IN
// ANY COMMUNICATION WITH YOU, INCLUDING, BUT NOT LIMITED TO,
// ANY IMPLIED WARRANTIES OF MERCHANTABILITY, SATISFACTORY
// QUALITY, FITNESS FOR ANY PARTICULAR PURPOSE,
// NONINFRINGEMENT, AND THEIR EQUIVALENTS.
//
//
// Written By:
//
// Description:
//
//   This file is supplied as part of the BAClon (BACnet over LonWorks) Toolkit
//
//////////////////////////////////////////////////////////////////////////////


// These units definitions are mapped onto the BACnet unit typedef values. Do not alter.

#pragma once

    /* Acceleration */
#define UNITS_METERS_PER_SECOND_PER_SECOND                  166
    /* Area */
#define UNITS_SQUARE_METERS                                 0
#define UNITS_SQUARE_CENTIMETERS                            116
#define UNITS_SQUARE_FEET                                   1
#define UNITS_SQUARE_INCHES                                 115
    /* Currency */
#define UNITS_CURRENCY1                                     105
#define UNITS_CURRENCY2                                     106
#define UNITS_CURRENCY3                                     107
#define UNITS_CURRENCY4                                     108
#define UNITS_CURRENCY5                                     109
#define UNITS_CURRENCY6                                     110
#define UNITS_CURRENCY7                                     111
#define UNITS_CURRENCY8                                     112
#define UNITS_CURRENCY9                                     113
#define UNITS_CURRENCY10                                    114
    /* Electrical */
#define UNITS_MILLIAMPERES                                  2
#define UNITS_AMPERES                                       3
#define UNITS_AMPERES_PER_METER                             167
#define UNITS_AMPERES_PER_SQUARE_METER                      168
#define UNITS_AMPERE_SQUARE_METERS                          169
#define UNITS_DECIBELS                                      199
#define UNITS_DECIBELS_MILLIVOLT                            200
#define UNITS_DECIBELS_VOLT                                 201
#define UNITS_FARADS                                        170
#define UNITS_HENRYS                                        171
#define UNITS_OHMS                                          4
#define UNITS_OHM_METERS                                    172
#define UNITS_MILLIOHMS                                     145
#define UNITS_KILOHMS                                       122
#define UNITS_MEGOHMS                                       123
#define UNITS_MICROSIEMENS                                  190
#define UNITS_MILLISIEMENS                                  202
#define UNITS_SIEMENS                                       173
#define UNITS_SIEMENS_PER_METER                             174
#define UNITS_TESLAS                                        175
#define UNITS_VOLTS                                         5
#define UNITS_MILLIVOLTS                                    124
#define UNITS_KILOVOLTS                                     6
#define UNITS_MEGAVOLTS                                     7
#define UNITS_VOLT_AMPERES                                  8
#define UNITS_KILOVOLT_AMPERES                              9
#define UNITS_MEGAVOLT_AMPERES                              10
#define UNITS_VOLT_AMPERES_REACTIVE                         11
#define UNITS_KILOVOLT_AMPERES_REACTIVE                     12
#define UNITS_MEGAVOLT_AMPERES_REACTIVE                     13
#define UNITS_VOLTS_PER_DEGREE_KELVIN                       176
#define UNITS_VOLTS_PER_METER                               177
#define UNITS_DEGREES_PHASE                                 14
#define UNITS_POWER_FACTOR                                  15
#define UNITS_WEBERS                                        178
    /* Energy */
#define UNITS_JOULES                                        16
#define UNITS_KILOJOULES                                    17
#define UNITS_KILOJOULES_PER_KILOGRAM                       125
#define UNITS_MEGAJOULES                                    126
#define UNITS_WATT_HOURS                                    18
#define UNITS_KILOWATT_HOURS                                19
#define UNITS_MEGAWATT_HOURS                                146
#define UNITS_WATT_HOURS_REACTIVE                           203
#define UNITS_KILOWATT_HOURS_REACTIVE                       204
#define UNITS_MEGAWATT_HOURS_REACTIVE                       205
#define UNITS_BTUS                                          20
#define UNITS_KILO_BTUS                                     147
#define UNITS_MEGA_BTUS                                     148
#define UNITS_THERMS                                        21
#define UNITS_TON_HOURS                                     22
    /* Enthalpy */
#define UNITS_JOULES_PER_KILOGRAM_DRY_AIR                   23
#define UNITS_KILOJOULES_PER_KILOGRAM_DRY_AIR               149
#define UNITS_MEGAJOULES_PER_KILOGRAM_DRY_AIR               150
#define UNITS_BTUS_PER_POUND_DRY_AIR                        24
#define UNITS_BTUS_PER_POUND                                117
    /* Entropy */
#define UNITS_JOULES_PER_DEGREE_KELVIN                      127
#define UNITS_KILOJOULES_PER_DEGREE_KELVIN                  151
#define UNITS_MEGAJOULES_PER_DEGREE_KELVIN                  152
#define UNITS_JOULES_PER_KILOGRAM_DEGREE_KELVIN             128
    /* Force */
#define UNITS_NEWTON                                        153
    /* Frequency */
#define UNITS_CYCLES_PER_HOUR                               25
#define UNITS_CYCLES_PER_MINUTE                             26
#define UNITS_HERTZ                                         27
#define UNITS_KILOHERTZ                                     129
#define UNITS_MEGAHERTZ                                     130
#define UNITS_PER_HOUR                                      131
    /* Humidity */
#define UNITS_GRAMS_OF_WATER_PER_KILOGRAM_DRY_AIR           28
#define UNITS_PERCENT_RELATIVE_HUMIDITY                     29
    /* Length */
#define UNITS_MICROMETERS                                   194
#define UNITS_MILLIMETERS                                   30
#define UNITS_CENTIMETERS                                   118
#define UNITS_KILOMETERS                                    193
#define UNITS_METERS                                        31
#define UNITS_INCHES                                        32
#define UNITS_FEET                                          33
    /* Light */
#define UNITS_CANDELAS                                      179
#define UNITS_CANDELAS_PER_SQUARE_METER                     180
#define UNITS_WATTS_PER_SQUARE_FOOT                         34
#define UNITS_WATTS_PER_SQUARE_METER                        35
#define UNITS_LUMENS                                        36
#define UNITS_LUXES                                         37
#define UNITS_FOOT_CANDLES                                  38
    /* Mass */
#define UNITS_MILLIGRAMS                                    196
#define UNITS_GRAMS                                         195
#define UNITS_KILOGRAMS                                     39
#define UNITS_POUNDS_MASS                                   40
#define UNITS_TONS                                          41
    /* Mass Flow */
#define UNITS_GRAMS_PER_SECOND                              154
#define UNITS_GRAMS_PER_MINUTE                              155
#define UNITS_KILOGRAMS_PER_SECOND                          42
#define UNITS_KILOGRAMS_PER_MINUTE                          43
#define UNITS_KILOGRAMS_PER_HOUR                            44
#define UNITS_POUNDS_MASS_PER_SECOND                        119
#define UNITS_POUNDS_MASS_PER_MINUTE                        45
#define UNITS_POUNDS_MASS_PER_HOUR                          46
#define UNITS_TONS_PER_HOUR                                 156
    /* Power */
#define UNITS_MILLIWATTS                                    132
#define UNITS_WATTS                                         47
#define UNITS_KILOWATTS                                     48
#define UNITS_MEGAWATTS                                     49
#define UNITS_BTUS_PER_HOUR                                 50
#define UNITS_KILO_BTUS_PER_HOUR                            157
#define UNITS_HORSEPOWER                                    51
#define UNITS_TONS_REFRIGERATION                            52
    /* Pressure */
#define UNITS_PASCALS                                       53
#define UNITS_HECTOPASCALS                                  133
#define UNITS_KILOPASCALS                                   54
#define UNITS_MILLIBARS                                     134
#define UNITS_BARS                                          55
#define UNITS_POUNDS_FORCE_PER_SQUARE_INCH                  56
#define UNITS_MILLIMETERS_OF_WATER                          206
#define UNITS_CENTIMETERS_OF_WATER                          57
#define UNITS_INCHES_OF_WATER                               58
#define UNITS_MILLIMETERS_OF_MERCURY                        59
#define UNITS_CENTIMETERS_OF_MERCURY                        60
#define UNITS_INCHES_OF_MERCURY                             61
    /* Temperature */
#define UNITS_DEGREES_CELSIUS                               62
#define UNITS_DEGREES_KELVIN                                63
#define UNITS_DEGREES_KELVIN_PER_HOUR                       181
#define UNITS_DEGREES_KELVIN_PER_MINUTE                     182
#define UNITS_DEGREES_FAHRENHEIT                            64
#define UNITS_DEGREE_DAYS_CELSIUS                           65
#define UNITS_DEGREE_DAYS_FAHRENHEIT                        66
#define UNITS_DELTA_DEGREES_FAHRENHEIT                      120
#define UNITS_DELTA_DEGREES_KELVIN                          121
    /* Time */
#define UNITS_YEARS                                         67
#define UNITS_MONTHS                                        68
#define UNITS_WEEKS                                         69
#define UNITS_DAYS                                          70
#define UNITS_HOURS                                         71
#define UNITS_MINUTES                                       72
#define UNITS_SECONDS                                       73
#define UNITS_HUNDREDTHS_SECONDS                            158
#define UNITS_MILLISECONDS                                  159
    /* Torque */
#define UNITS_NEWTON_METERS                                 160
    /* Velocity */
#define UNITS_MILLIMETERS_PER_SECOND                        161
#define UNITS_MILLIMETERS_PER_MINUTE                        162
#define UNITS_METERS_PER_SECOND                             74
#define UNITS_METERS_PER_MINUTE                             163
#define UNITS_METERS_PER_HOUR                               164
#define UNITS_KILOMETERS_PER_HOUR                           75
#define UNITS_FEET_PER_SECOND                               76
#define UNITS_FEET_PER_MINUTE                               77
#define UNITS_MILES_PER_HOUR                                78
    /* Volume */
#define UNITS_CUBIC_FEET                                    79
#define UNITS_CUBIC_METERS                                  80
#define UNITS_IMPERIAL_GALLONS                              81
#define UNITS_MILLILITERS                                   197
#define UNITS_LITERS                                        82
#define UNITS_US_GALLONS                                    83
    /* Volumetric Flow */
#define UNITS_CUBIC_FEET_PER_SECOND                         142
#define UNITS_CUBIC_FEET_PER_MINUTE                         84
#define UNITS_CUBIC_FEET_PER_HOUR                           191
#define UNITS_CUBIC_METERS_PER_SECOND                       85
#define UNITS_CUBIC_METERS_PER_MINUTE                       165
#define UNITS_CUBIC_METERS_PER_HOUR                         135
#define UNITS_IMPERIAL_GALLONS_PER_MINUTE                   86
#define UNITS_MILLILITERS_PER_SECOND                        198
#define UNITS_LITERS_PER_SECOND                             87
#define UNITS_LITERS_PER_MINUTE                             88
#define UNITS_LITERS_PER_HOUR                               136
#define UNITS_US_GALLONS_PER_MINUTE                         89
#define UNITS_US_GALLONS_PER_HOUR                           192
    /* Other */
#define UNITS_DEGREES_ANGULAR                               90
#define UNITS_DEGREES_CELSIUS_PER_HOUR                      91
#define UNITS_DEGREES_CELSIUS_PER_MINUTE                    92
#define UNITS_DEGREES_FAHRENHEIT_PER_HOUR                   93
#define UNITS_DEGREES_FAHRENHEIT_PER_MINUTE                 94
#define UNITS_JOULE_SECONDS                                 183
#define UNITS_KILOGRAMS_PER_CUBIC_METER                     186
#define UNITS_KW_HOURS_PER_SQUARE_METER                     137
#define UNITS_KW_HOURS_PER_SQUARE_FOOT                      138
#define UNITS_MEGAJOULES_PER_SQUARE_METER                   139
#define UNITS_MEGAJOULES_PER_SQUARE_FOOT                    140
#define UNITS_NO_UNITS                                      95
#define UNITS_NEWTON_SECONDS                                187
#define UNITS_NEWTONS_PER_METER                             188
#define UNITS_PARTS_PER_MILLION                             96
#define UNITS_PARTS_PER_BILLION                             97
#define UNITS_PERCENT                                       98
#define UNITS_PERCENT_OBSCURATION_PER_FOOT                  143
#define UNITS_PERCENT_OBSCURATION_PER_METER                 144
#define UNITS_PERCENT_PER_SECOND                            99
#define UNITS_PER_MINUTE                                    100
#define UNITS_PER_SECOND                                    101
#define UNITS_PSI_PER_DEGREE_FAHRENHEIT                     102
#define UNITS_RADIANS                                       103
#define UNITS_RADIANS_PER_SECOND                            184
#define UNITS_REVOLUTIONS_PER_MINUTE                        104
#define UNITS_SQUARE_METERS_PER_NEWTON                      185
#define UNITS_WATTS_PER_METER_PER_DEGREE_KELVIN             189
#define UNITS_WATTS_PER_SQUARE_METER_DEGREE_KELVIN          141
#define UNITS_PER_MILLE                                     207
#define UNITS_GRAMS_PER_GRAM                                208
#define UNITS_KILOGRAMS_PER_KILOGRAM                        209
#define UNITS_GRAMS_PER_KILOGRAM                            210
#define UNITS_MILLIGRAMS_PER_GRAM                           211
#define UNITS_MILLIGRAMS_PER_KILOGRAM                       212
#define UNITS_GRAMS_PER_MILLILITER                          213
#define UNITS_GRAMS_PER_LITER                               214
#define UNITS_MILLIGRAMS_PER_LITER                          215
#define UNITS_MICROGRAMS_PER_LITER                          216
#define UNITS_GRAMS_PER_CUBIC_METER                         217
#define UNITS_MILLIGRAMS_PER_CUBIC_METER                    218
#define UNITS_MICROGRAMS_PER_CUBIC_METER                    219
#define UNITS_NANOGRAMS_PER_CUBIC_METER                     220
#define UNITS_GRAMS_PER_CUBIC_CENTIMETER                    221
#define UNITS_BECQUERELS                                    222
#define UNITS_MEGABECQUERELS                                224
#define UNITS_GRAY                                          225
#define UNITS_MILLIGRAY                                     226
#define UNITS_MICROGRAY                                     227
#define UNITS_SIEVERTS                                      228
#define UNITS_MILLISIEVERTS                                 229
#define UNITS_MICROSIEVERTS                                 230
#define UNITS_MICROSIEVERTS_PER_HOUR                        231
#define UNITS_DECIBELS_A                                    232
#define UNITS_NEPHELOMETRIC_TURBIDITY_UNIT                  233
#define UNITS_PH                                            234
#define UNITS_GRAMS_PER_SQUARE_METER                        235
#define UNITS_MINUTES_PER_DEGREE_KELVIN                     236

