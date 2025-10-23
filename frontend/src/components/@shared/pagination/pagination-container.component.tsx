import {
  Pagination,
  PaginationContent,
  PaginationItem,
  PaginationLink,
  PaginationNext,
  PaginationPrevious,
  PaginationEllipsis,
} from "@/components/ui/pagination";
import ItemsPerPageSelector from "./items-per-page-selector.component";

type PaginationContainerProps = {
  page: number;
  totalPages: number;
  setPage: (page: number) => void;
  itemsPerPage: string;
  setItemsPerPage: (itemsPerPage: string) => void;
};

export default function PaginationContainer(props: PaginationContainerProps) {
  const { page, totalPages, setPage, itemsPerPage, setItemsPerPage } = props;

  const handlePageChange = (newPage: number) => {
    if (newPage < 1 || newPage > totalPages) {
      return;
    }
    setPage(newPage);
  };

  const showPaginationItems = (start: number, end: number) => {
    return Array.from({ length: end - start + 1 }, (_, index) => {
      const pageNumber = start + index;

      return (
        <PaginationItem key={pageNumber}>
          <PaginationLink
            onClick={() => handlePageChange(pageNumber)}
            className={`cursor-pointer hover:bg-card hover:text-white ${page === pageNumber ? "bg-primary text-white" : ""}`}
          >
            {pageNumber}
          </PaginationLink>
        </PaginationItem>
      );
    });
  };

  const getPagination = () => {
    const totalPageNumbers = 6;

    if (totalPageNumbers >= totalPages) {
      return showPaginationItems(1, totalPages);
    }

    const leftSibling = Math.max(page - 2, 1);
    const rightSibling = Math.min(page + 2, totalPages);

    const showLeftDots = leftSibling > 2;
    const showRightDots = rightSibling < totalPages - 2;

    if (!showLeftDots && showRightDots) {
      const leftCount = 5;

      return (
        <>
          {showPaginationItems(1, leftCount)}

          <PaginationItem>
            <PaginationEllipsis />
          </PaginationItem>

          <PaginationItem key={totalPages}>
            <PaginationLink
              onClick={() => handlePageChange(totalPages)}
              className={`cursor-pointer hover:bg-card hover:text-white ${page === totalPages ? "bg-primary text-white" : ""}`}
            >
              {totalPages}
            </PaginationLink>
          </PaginationItem>
        </>
      );
    }

    if (showLeftDots && showRightDots) {
      return (
        <>
          <PaginationItem key={1}>
            <PaginationLink
              onClick={() => handlePageChange(1)}
              className={`cursor-pointer hover:bg-card hover:text-white ${page === 1 ? "bg-primary text-white" : ""}`}
            >
              {1}
            </PaginationLink>
          </PaginationItem>

          <PaginationItem>
            <PaginationEllipsis />
          </PaginationItem>

          {showPaginationItems(leftSibling + 1, rightSibling - 1)}

          <PaginationItem>
            <PaginationEllipsis />
          </PaginationItem>

          <PaginationItem key={totalPages}>
            <PaginationLink
              onClick={() => handlePageChange(totalPages)}
              className={`cursor-pointer hover:bg-card hover:text-white ${page === totalPages ? "bg-primary text-white" : ""}`}
            >
              {totalPages}
            </PaginationLink>
          </PaginationItem>
        </>
      );
    }

    if (showLeftDots && !showRightDots) {
      const rightCount = 5;

      return (
        <>
          <PaginationItem key={1}>
            <PaginationLink
              onClick={() => handlePageChange(1)}
              className={`cursor-pointer hover:bg-card hover:text-white ${page === 1 ? "bg-primary text-white" : ""}`}
            >
              {1}
            </PaginationLink>
          </PaginationItem>

          <PaginationItem>
            <PaginationEllipsis />
          </PaginationItem>

          {showPaginationItems(totalPages - rightCount + 1, totalPages)}
        </>
      );
    }
  };

  return (
    <div className="flex justify-center gap-2">
      <Pagination className="w-max m-0">
        <PaginationContent>
          <PaginationItem key="prev">
            <PaginationPrevious
              className="hover:bg-card hover:text-white cursor-pointer"
              onClick={(e) => {
                e.preventDefault();
                handlePageChange(page - 1);
              }}
            />
          </PaginationItem>

          {getPagination()}

          <PaginationItem key="next">
            <PaginationNext
              className="hover:bg-card hover:text-white cursor-pointer"
              onClick={(e) => {
                e.preventDefault();
                handlePageChange(page + 1);
              }}
            />
          </PaginationItem>
        </PaginationContent>
      </Pagination>
      <ItemsPerPageSelector
        itemsPerPage={itemsPerPage}
        setItemsPerPage={setItemsPerPage}
      />
    </div>
  );
}
