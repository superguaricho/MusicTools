# Makefile for the MusicTools project

# --- Configuration Variables ---

# Command to invoke Agda
AGDA = agda
# Main Agda file
AGDA_MAIN = agda/Main.agda

# Flags to pass to GHC when compiling with Agda.
# Including all .cabal dependencies for robustness.
GHC_FLAGS = --ghc-flag="-package text" \
            --ghc-flag="-package HCodecs"

# Full command to compile Agda to Haskell
AGDA_COMPILE_CMD = $(AGDA) -c $(AGDA_MAIN) $(GHC_FLAGS)

# Command to invoke Cabal
CABAL = cabal


# --- Build Rules ---

# The default rule: 'make' or 'make all' will build the executable.
all: build

# Rule to build the Haskell executable.
# First ensures that the 'agda' rule has been executed.
build:
	@echo "--> Building the Haskell executable with Cabal..."
	@cd haskell && $(CABAL) build

# Rule to compile Agda code to Haskell.
agda/Main:
	@echo "--> Compiling Agda code to Haskell..."
	@$(AGDA_COMPILE_CMD)

main:agda/Main
	@if [ -z agda/Main ]; then make agda/Main; @echo agda/Main exists; fi

# Define test.mid as a target that depends on agda
test.mid: agda/Main
	@echo "--> Creating test.mid file..."
	agda/Main

# Make play depend on test.mid. You need timidity
play: test.mid
	@echo "--> Playing test.mid file..."
	timidity test.mid -Os

# Rule to clean all generated files.
clean:
	@echo "--> Cleaning generated files..."
	@rm -rf agda/MAlonzo
	@rm -rf agda/Main
	@rm -rf test.mid
	@cd haskell && $(CABAL) clean
	@echo "--> Cleaning completed."

# Declares that these rules do not produce files with their own name.
.PHONY: all build main play clean

