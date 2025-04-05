import 'dart:ui';

class Quadtree<T> {
  final Rect boundary;
  final int capacity;
  final Offset Function(T) getPoint;
  List<T> points = [];
  bool divided = false;
  Quadtree<T>? northeast;
  Quadtree<T>? northwest;
  Quadtree<T>? southeast;
  Quadtree<T>? southwest;

  Quadtree(this.boundary, this.capacity, this.getPoint);

  bool insert(T point) {
    if (!boundary.contains(getPoint(point))) return false;

    if (points.length < capacity) {
      points.add(point);
      return true;
    } else {
      if (!divided) {
        subdivide();
      }
      return northeast!.insert(point) ||
          northwest!.insert(point) ||
          southeast!.insert(point) ||
          southwest!.insert(point);
    }
  }

  void subdivide() {
    final double x = boundary.left;
    final double y = boundary.top;
    final double w = boundary.width / 2;
    final double h = boundary.height / 2;

    final Rect ne = Rect.fromLTWH(x + w, y, w, h);
    final Rect nw = Rect.fromLTWH(x, y, w, h);
    final Rect se = Rect.fromLTWH(x + w, y + h, w, h);
    final Rect sw = Rect.fromLTWH(x, y + h, w, h);

    northeast = Quadtree<T>(ne, capacity, getPoint);
    northwest = Quadtree<T>(nw, capacity, getPoint);
    southeast = Quadtree<T>(se, capacity, getPoint);
    southwest = Quadtree<T>(sw, capacity, getPoint);
    divided = true;
  }

  List<T> query(Rect range, [List<T>? found]) {
    found ??= [];
    if (!boundary.overlaps(range)) {
      return found;
    } else {
      for (T point in points) {
        if (range.contains(getPoint(point))) {
          found.add(point);
        }
      }
      if (divided) {
        northeast!.query(range, found);
        northwest!.query(range, found);
        southeast!.query(range, found);
        southwest!.query(range, found);
      }
      return found;
    }
  }
}
