DefinitionBlock ("", "SSDT", 2, "FIXUP", "LIDWAKE", 0x00000001)
{
    External (\_SB.PC00.LPCB.LID0, DeviceObj)

    Scope (\_SB.PC00.LPCB.LID0)
    {
        Name (_PRW, Package (0x02)
        {
            0x02,
            Zero
        })
    }
}
