import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "../../ui/select";
import { Label } from "../../ui/label";

interface ItemsPerPageProps {
  itemsPerPage: string;
  setItemsPerPage: (itemsPerPage: string) => void;
}

export default function ItemsPerPageSelector(props: ItemsPerPageProps) {
  const { itemsPerPage, setItemsPerPage } = props;

  return (
    <div className="flex gap-2">
      <Label>Itens por página</Label>
      <Select
        value={itemsPerPage}
        onValueChange={(value) => setItemsPerPage(value)}
      >
        <SelectTrigger className="w-fit cursor-pointer border-card">
          <SelectValue placeholder="Selecionar" />
        </SelectTrigger>
        <SelectContent className="bg-background text-white border-card">
          <SelectItem
            className="cursor-pointer data-[highlighted]:bg-card data-[highlighted]:text-white"
            value="5"
          >
            5
          </SelectItem>
          <SelectItem
            className="cursor-pointer data-[highlighted]:bg-card data-[highlighted]:text-white"
            value="10"
          >
            10
          </SelectItem>
          <SelectItem
            className="cursor-pointer data-[highlighted]:bg-card data-[highlighted]:text-white"
            value="15"
          >
            15
          </SelectItem>
          <SelectItem
            className="cursor-pointer data-[highlighted]:bg-card data-[highlighted]:text-white"
            value="25"
          >
            25
          </SelectItem>
          <SelectItem
            className="cursor-pointer data-[highlighted]:bg-card data-[highlighted]:text-white"
            value="50"
          >
            50
          </SelectItem>
        </SelectContent>
      </Select>
    </div>
  );
}
