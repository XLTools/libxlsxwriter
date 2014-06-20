/*****************************************************************************
 * Test cases for libxlsxwriter.
 *
 * Simple test case to test worksheet set_row() and set_column().
 *
 * Copyright 2014, John McNamara, jmcnamara@cpan.org
 *
 */

#include "xlsxwriter.h"

int main() {

    lxw_workbook  *workbook     = new_workbook("test_row_col_format13.xlsx");
    lxw_worksheet *worksheet    = workbook_add_worksheet(workbook, NULL);
    lxw_row_col_options options = {1, 0, 0};
    lxw_format    *bold         = workbook_add_format(workbook);

    format_set_bold(bold);

    worksheet_set_column(worksheet, 1, 3, 5, NULL, NULL);
    worksheet_set_column(worksheet, 5, 5, 8, NULL, &options);
    worksheet_set_column(worksheet, 7, 7, LXW_DEF_COL_WIDTH, bold, NULL);
    worksheet_set_column(worksheet, 9, 9, 2, NULL, NULL);
    worksheet_set_column(worksheet, 11, 11, LXW_DEF_COL_WIDTH, NULL, &options);

    return workbook_close(workbook);
}