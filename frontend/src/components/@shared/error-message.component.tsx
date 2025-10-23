interface ErrorMessageProps {
  direction: "row" | "col";
  message: string;
  textsize?: string;
}

export default function ErrorMessage(props: ErrorMessageProps) {
  const { direction, message, textsize } = props;

  return (
    <div
      className={`flex gap-1 ${direction === "col" ? "flex-col items-center" : "flex-row items-center"}`}
    >
      <p className={`text-red-500 ${textsize}`}>{message}</p>
    </div>
  );
}
