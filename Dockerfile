FROM rakudo-star:latest

LABEL maintainer="Jovan Trujillo"
LABEL description="TrueBASIC7 — A True BASIC interpreter written in Raku"

# Install system dependencies for GTK/Cairo graphics support
RUN apt-get update && apt-get install -y --no-install-recommends \
        libgtk-3-dev \
        libcairo2-dev \
        gobject-introspection \
        libgirepository1.0-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Raku GTK/Cairo modules
RUN zef install --/test Gnome::Gtk3 Gnome::Cairo

WORKDIR /app

# Copy interpreter and library modules first (changes less often)
COPY lib/ lib/
COPY TrueBASIC.raku .

# Copy examples and tests
COPY examples/ examples/
COPY test/ test/

# Copy documentation
COPY README.md .
COPY GTK_INSTALLATION_GUIDE.md .

# Default to SVG graphics (no display required in container)
ENV TRUEBASIC_GRAPHICS=svg

# Create an output directory for generated plots
RUN mkdir -p /app/output

ENTRYPOINT ["raku", "TrueBASIC.raku"]
CMD ["--help"]
