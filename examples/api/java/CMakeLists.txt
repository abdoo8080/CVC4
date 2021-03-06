###############################################################################
# Top contributors (to current version):
#   Andres Noetzli, Aina Niemetz, Mathias Preiner
#
# This file is part of the cvc5 project.
#
# Copyright (c) 2009-2021 by the authors listed in the file AUTHORS
# in the top-level source directory and their institutional affiliations.
# All rights reserved.  See the file COPYING in the top-level source
# directory for licensing information.
# #############################################################################
#
# The build system configuration.
##

set(EXAMPLES_API_JAVA
  ## disabled until bindings for the new API are in place (issue #2284)
  # BitVectors
  # BitVectorsAndArrays
  # CVC5Streams
  # Combination
  # Datatypes
  # Exceptions
  # FloatingPointArith
  # HelloWorld
  # LinearArith
  # PipedInput
  # Relations
  # Statistics
  # Strings
  # UnsatCores
)

foreach(example ${EXAMPLES_API_JAVA})
  add_jar(${example} ${example}.java
          INCLUDE_JARS "${CVC5_JAR}"
          OUTPUT_DIR "${CMAKE_BINARY_DIR}/bin/api/java")

  set(EXAMPLE_TEST_NAME api/java/${example})

  add_test(
    NAME ${EXAMPLE_TEST_NAME}
    COMMAND
      ${Java_JAVA_EXECUTABLE}
        -cp "${CVC5_JAR}:${CMAKE_BINARY_DIR}/bin/api/java/${example}.jar"
        -Djava.library.path=${CVC5_JNI_PATH}
        ${example}
  )
  set_tests_properties(${EXAMPLE_TEST_NAME} PROPERTIES SKIP_RETURN_CODE 77)
endforeach()
