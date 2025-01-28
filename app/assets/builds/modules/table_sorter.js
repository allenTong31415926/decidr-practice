export class TableSorter {
    constructor() {
        this.tableData = null;
        document.addEventListener('turbo:load', () => this.initialize());
    }
    initialize() {
        const table = document.querySelector('table');
        if (!table)
            return;
        const tbody = table.querySelector('tbody');
        const headers = table.querySelectorAll('th');
        if (!tbody)
            return;
        this.tableData = { table, tbody, headers };
        this.attachEventListeners();
    }
    attachEventListeners() {
        if (!this.tableData)
            return;
        this.tableData.headers.forEach((header, index) => {
            if (header.classList.contains('sortable')) {
                header.addEventListener('click', () => this.sortTable(index));
            }
        });
    }
    sortTable(columnIndex) {
        if (!this.tableData)
            return;
        const { table, tbody, headers } = this.tableData;
        const header = headers[columnIndex];
        if (!header || !header.classList.contains('sortable'))
            return;
        const currentDir = header.getAttribute('data-sort-dir') || 'asc';
        const newDir = currentDir === 'asc' ? 'desc' : 'asc';
        headers.forEach(h => h.removeAttribute('data-sort-dir'));
        header.setAttribute('data-sort-dir', newDir);
        const rows = Array.from(tbody.querySelectorAll('tr'));
        this.sortRows(rows, columnIndex, newDir);
        tbody.innerHTML = '';
        rows.forEach(row => tbody.appendChild(row));
    }
    sortRows(rows, columnIndex, direction) {
        rows.sort((a, b) => {
            const aValue = a.children[columnIndex]?.textContent?.trim() || '';
            const bValue = b.children[columnIndex]?.textContent?.trim() || '';
            return direction === 'asc'
                ? aValue.localeCompare(bValue)
                : bValue.localeCompare(aValue);
        });
    }
}
//# sourceMappingURL=table_sorter.js.map