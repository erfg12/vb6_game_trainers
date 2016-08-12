using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;

namespace WindowsFormsApplication3
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        [DllImport("kernel32.dll")]
        public static extern IntPtr OpenProcess(
            UInt32 dwDesiredAccess,
            Int32 bInheritHandle,
            Int32 dwProcessId
            );

        [DllImport("kernel32.dll")]
        private static extern bool WriteProcessMemory(IntPtr hProcess, UIntPtr lpBaseAddress, byte[] lpBuffer, UIntPtr nSize, IntPtr lpNumberOfBytesWritten);

        public void writeByte(UIntPtr code, byte[] write, int size)
        {
            WriteProcessMemory(pHandle, code, write, (UIntPtr)size, IntPtr.Zero);
        }

        private ProcessModule mainModule;
        public static IntPtr pHandle;
        public Process procs = null;
        public Dictionary<string, IntPtr> modules = new Dictionary<string, IntPtr>();

        public void getModules()
        {
            if (procs == null)
                return;

            modules.Clear();
            foreach (ProcessModule Module in procs.Modules)
            {
                if (Module.ModuleName != "" && Module.ModuleName != null && !modules.ContainsKey(Module.ModuleName))
                    modules.Add(Module.ModuleName, Module.BaseAddress);
            }
        }

        public bool OpenGameProcess(int procID)
        {
            if (procID != 0) //getProcIDFromName returns 0 if there was a problem
                procs = Process.GetProcessById(procID);
            else
                return false;

            if (procs.Responding == false)
                return false;

            pHandle = OpenProcess(0x1F0FFF, 1, procID);
            mainModule = procs.MainModule;
            getModules();
            return true;
        }

        public int getProcIDFromName(string name)
        {
            Process[] processlist = Process.GetProcesses();
            string theProc = name.ToLower();

            foreach (Process theprocess in processlist)
            {
                if (theprocess.ProcessName.ToLower().Contains(theProc))
                    return theprocess.Id;
            }

            return 0;
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            int procID = getProcIDFromName("chips");
            //MessageBox.Show(procID.ToString());
            label2.Text = procID.ToString();
            OpenGameProcess(procID);
            /*if (OpenGameProcess(procID))
                MessageBox.Show("process is now open");
            else
                MessageBox.Show("failed to open");*/
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            byte[] memory = new byte[1];
            memory = BitConverter.GetBytes(99);
            UIntPtr base1 = new UIntPtr(0x80DD41B4);
            WriteProcessMemory(pHandle, base1, memory, (UIntPtr)1, IntPtr.Zero);
            /*if (WriteProcessMemory(pHandle, base1, memory, (UIntPtr)1, IntPtr.Zero))
                MessageBox.Show("worked");
            else
                MessageBox.Show("didnt work");*/
        }
    }
}
