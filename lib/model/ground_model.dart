class Ground {
  final String title;
  final String subtitle;
  final int price;
  final double rating;
  final String image;
  final bool recommended;

  Ground(
      this.title,
      this.subtitle,
      this.price,
      this.rating,
      this.image, {
        this.recommended = false,
      });
}
