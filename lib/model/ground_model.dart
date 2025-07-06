class Ground {
  final String title;
  final String subtitle;
  final int price;
  final double rating;
  final List<String> images;
  final bool recommended;
  final double lat;
  final double lng;

  Ground(
      this.title,
      this.subtitle,
      this.price,
      this.rating,
      this.images, {
        this.recommended = false,
        required this.lat,
        required this.lng,
      });
}
