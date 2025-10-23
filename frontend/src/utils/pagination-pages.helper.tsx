export default function getVisiblePages(
  currentPage: number,
  totalPages: number,
): number[] {
  const totalPageNumbers = 6;

  if (totalPages <= totalPageNumbers) {
    return Array.from({ length: totalPages }, (_, i) => i + 1);
  }

  const leftSibling = Math.max(currentPage - 2, 1);
  const rightSibling = Math.min(currentPage + 2, totalPages);

  const showLeftDots = leftSibling > 2;
  const showRightDots = rightSibling < totalPages - 2;

  if (!showLeftDots && showRightDots) {
    return [...Array(5)].map((_, i) => i + 1).concat([totalPages]);
  }

  if (showLeftDots && showRightDots) {
    return [1, currentPage - 1, currentPage, currentPage + 1, totalPages];
  }

  if (showLeftDots && !showRightDots) {
    return [
      1,
      ...Array(5)
        .fill(null)
        .map((_, i) => totalPages - 4 + i),
    ];
  }

  return [currentPage];
}
