import { SortDirection, TableData } from '../types/table';

export class TableSorter {
  private tableData: TableData | null = null;

  constructor() {
    document.addEventListener('turbo:load', () => this.initialize());
  }

  private initialize(): void {
    const table = document.querySelector('table');
    if (!table) return;

    const tbody = table.querySelector('tbody');
    const headers = table.querySelectorAll('th');
    
    if (!tbody) return;

    this.tableData = { table, tbody, headers };
    this.attachEventListeners();
  }

  private attachEventListeners(): void {
    if (!this.tableData) return;

    this.tableData.headers.forEach((header, index) => {
      if (header.classList.contains('sortable')) {
        header.addEventListener('click', () => this.sortTable(index));
      }
    });
  }

  private sortTable(columnIndex: number): void {
    if (!this.tableData) return;
    const { table, tbody, headers } = this.tableData;

    const header = headers[columnIndex];
    if (!header || !header.classList.contains('sortable')) return;

    const currentDir = header.getAttribute('data-sort-dir') as SortDirection || 'asc';
    const newDir: SortDirection = currentDir === 'asc' ? 'desc' : 'asc';

    headers.forEach(h => h.removeAttribute('data-sort-dir'));
    header.setAttribute('data-sort-dir', newDir);

    const rows = Array.from(tbody.querySelectorAll('tr'));
    this.sortRows(rows, columnIndex, newDir);

    tbody.innerHTML = '';
    rows.forEach(row => tbody.appendChild(row));
  }

  private sortRows(rows: HTMLTableRowElement[], columnIndex: number, direction: SortDirection): void {
    rows.sort((a, b) => {
      const aValue = a.children[columnIndex]?.textContent?.trim() || '';
      const bValue = b.children[columnIndex]?.textContent?.trim() || '';

      return direction === 'asc' 
        ? aValue.localeCompare(bValue)
        : bValue.localeCompare(aValue);
    });
  }
} 