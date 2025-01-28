export type SortDirection = 'asc' | 'desc';

export interface TableData {
  table: HTMLTableElement;
  tbody: HTMLTableSectionElement;
  headers: NodeListOf<HTMLTableCellElement>;
} 