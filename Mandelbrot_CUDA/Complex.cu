
template <class T>
class Complex {
 private:
  T _real;
  T _imag;

 public:
  __device__ Complex() {
    this->_real = 0;
    this->_imag = 0;
  }

  __device__ Complex(T real, T imag) {
    this->_real = real;
    this->_imag = imag;
  }

  __device__ T real() { return this->_real; }

  __device__ T imag() { return this->_imag; }

  __device__ void real(T& real) { this->_real = real; }

  __device__ void imag(T& imag) { this->_imag = imag; }

  __device__ Complex<T> operator+(Complex<T>& c) {
    return Complex<T>(this->real() + c.real(), this->imag() + c.imag());
  }

  __device__ Complex<T> operator+(T& r) {
    return Complex<T>(this->real() + r, this->imag());
  }

  __device__ Complex<T> operator-(Complex<T>& c) {
    return Complex<T>(this->real() - c.real(), this->real() - c.real());
  }

  __device__ Complex<T> operator-(T& r) {
    return Complex<T>(this->real() - r, this->imag());
  }

  __device__ Complex<T> operator*(Complex<T>& c) {
    return Complex<T>(this->real() * c.real() - this->imag() * c.imag(),
                      this->real() * c.imag() + this->imag() * c.real());
  }

  __device__ Complex<T> operator*(T& r) {
    return Complex<T>(r * this->real(), r * this->imag());
  }

  __device__ Complex<T> operator/(Complex<T>& c) {
    T normalizer = c.real() * c.real() + c.imag() * c.imag();
    return Complex<T>(
        (this->real() * c.real() + this->imag() * c.imag()) / normalizer,
        (this->real() * c.imag() + this->imag() * c.real()) / normalizer);
  }

  __device__ Complex<T> operator/(T& r) {
    return Complex<T>(this->real() / r, this->imag() / r);
  }

  __device__ T abs() {
    return sqrt(this->real() * this->real() + this->imag() * this->imag());
  }
};
