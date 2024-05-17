//////////////////////////////////////////////////////////////////////////////
// Filesys.h
//
// LON file transfer support header file.
//
// Copyright © 2009-2021 Dialog Semiconductor.
//
// This file is licensed under the terms of the MIT license available at
// https://choosealicense.com/licenses/mit/.
//////////////////////////////////////////////////////////////////////////////

#ifndef _FILESYS_H_
#define _FILESYS_H_

//////////////////////////////////////////////////////////////////////////////
// Header Files
#include <s32.h>
#include <SNVT_fr.h>
#include <SNVT_fs.h>

//////////////////////////////////////////////////////////////////////////////
// DEFINES

// FTP_SUPPORT_CREATE -- Uncomment the following macro to allow for create() 
// calls to be made and files to be added and/or being replaced dynamically. 
// Address the notes about the create() function in filesys.nc prior to enabling 
// this feature.  On a device that only only accomodates CP-related files, 
// support for dynamic creation is not required. Dynamic creation of files 
// requires the FTP client software to support this feature.  
//#define FTP_SUPPORT_CREATE

// DIRECTORY STORAGE -- The file directory can be stored in read-only memory 
// unless dynamic creation of files is required.
#ifdef  FTP_SUPPORT_CREATE
#   define  DIRECTORY_STORAGE   far eeprom
#else
#   define  DIRECTORY_STORAGE   const far
#endif   // ftp_support_create

#define NULL_HANDLE -1
#define FILE_INFO_SIZE 16               // directory information

// FILE_ENUM_T -- Enumeration of file types, see the LON File Transfer Protocol 
// specification for more details.
typedef enum  {
    VALUE_TYPE      = 1,                // 1
    TEMPLATE_TYPE,                      // 2
    LAST_FILE = TEMPLATE_TYPE           // 2
} FILE_ENUM_T;

// FILEPTR_T -- The pointer to a file's data area can point to read-only memory, 
// and it can point to writable memory. Define a union to meet the compiler's 
// requirements in both cases.
typedef union  {
    void* const readOnly;
    void* byteBase;
} FILEPTR_T;

#define TEMPLATE_FILEINDEX 0
#define VALUE_FILEINDEX 1
#define CONST_FILEINDEX 2

#define NULL_INFO   ""

#define FILE_DIRECTORY_VERSION 0x20

#ifndef _USE_NO_CPARAMS_ACCESS
#   ifdef _USE_FTP_CPARAMS_ACCESS

        typedef   signed long   file_handle;            // host operating system dependent
        typedef unsigned long   file_index;

        // The following union type is used to hold the size of a FTP file in the 
        // FTP file directory. The LON FTP protocol requires the file size to be a 
        // 32-bit number of type s32_type. However, for initialization of a constant
        // (thus "ROM-able") FTP file directory, we want to initialize the standard 
        // files' size fields with the compiler built-ins cp_template_file_len, 
        // cp_readonly_value_file_len, and cp_modifiable_value_file_len. The latter 
        // symbols are 16-bit initializers, owing to the fact that the both the Neuron 
        // core and the Neuron C Compiler are limited to a 16-bit (64kB) physical
        // address space. Do not use the union member _dwsize union member explicitly 
        // in your code. Use the functions from the s32 library and the s32size union 
        // member instead.

        typedef union  {
            struct  {
                unsigned long uHighWord;
                unsigned long uLowWord;
            } _dwsize;
            s32_type        s32size;
        } file_size;

        typedef struct  {
            char            info[FILE_INFO_SIZE];
            file_size       size;           // File size, unsigned 32 bits
            unsigned long   type;           // File type, 16 bits
        } file_descriptor;                  // Directory entry

        typedef struct  {
            file_descriptor fileDescriptor;
            const FILEPTR_T fileData;
        } TFileDescriptor;

#   else
#       ifdef _USE_DIRECT_CPARAMS_ACCESS

            typedef struct  {
                unsigned long   fileSize;   // Memory r/w only allows for files <= 64kB
                unsigned long   fileType;   // Directory version #2
                const FILEPTR_T fileData;
            } TFileDescriptor;
#       else
#           error   "Either _USE_DIRECT_CPARAMS_ACCESS or _USE_FTP_CPARAMS_ACCESS must be defined"
#       endif // def. _use_direct_*

#   endif // def. _USE_FTP_*

    typedef struct  {
        int     version;     // Code wizard only supports directory version 0x20
        // See LonMark Guidelines, section 4, for guidance with
        // respect to directory version 0x11
        int     numFiles;
        TFileDescriptor files[NUM_FILES];
    } TFileDirectory;

    extern DIRECTORY_STORAGE TFileDirectory FileDirectory;
#endif // ndef. _USE_NO_CPARAMS_ACCESS

#endif //_FILESYS_
