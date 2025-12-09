# Makefile para el proyecto MusicTools

# --- Variables de Configuración ---

# Comando para invocar Agda
AGDA = agda
# Archivo principal de Agda
AGDA_MAIN = agda/Main.agda

# Banderas para pasar a GHC al compilar con Agda.
# Incluyo todas las dependencias del .cabal para ser robustos.
GHC_FLAGS = --ghc-flag="-package text" \
            --ghc-flag="-package HCodecs"

# Comando completo para compilar Agda a Haskell
AGDA_COMPILE_CMD = $(AGDA) -c $(AGDA_MAIN) $(GHC_FLAGS)

# Comando para invocar Cabal
CABAL = cabal


# --- Reglas de Construcción ---

# La regla por defecto: 'make' o 'make all' construirán el ejecutable.
all: build

# Regla para construir el ejecutable de Haskell.
# Primero se asegura de que la regla 'agda' se haya ejecutado.
build: agda
	@echo "--> Construyendo el ejecutable de Haskell con Cabal..."
	@cd haskell && $(CABAL) build

# Regla para compilar el código de Agda a Haskell.
agda:
	@echo "--> Compilando el código de Agda a Haskell..."
	@$(AGDA_COMPILE_CMD)

midi: agda
	@echo "--> Creando el archivo test.mid..."
	agda/Main 

play:
	@if [ ! -f test.mid ]; then \
		echo "--> test.mid no existe. Generando..."; \
		$(MAKE) midi; \
	fi
	@echo "--> Reproduciendo el archivo test.mid..."
	timidity test.mid -Os

# Regla para limpiar todos los archivos generados.
clean:
	@echo "--> Limpiando archivos generados..."
	@rm -rf agda/MAlonzo
	@rm -rf agda/Main
	@rm -rf test.mid
	@cd haskell && $(CABAL) clean
	@echo "--> Limpieza completada."

# Declara que estas reglas no producen archivos con su mismo nombre.
.PHONY: all build agda clean
