struct Color {
  unsigned char red;
  unsigned char green;
  unsigned char blue;
  unsigned char alpha;

  Color(unsigned char red, unsigned char green, unsigned char blue,
        unsigned char alpha) {
    this->red = red;
    this->green = green;
    this->blue = blue;
    this->alpha = alpha;
  }

  Color(unsigned char red, unsigned char green, unsigned char blue) {
    this->red = red;
    this->green = green;
    this->blue = blue;
    this->alpha = 255;
  }
};