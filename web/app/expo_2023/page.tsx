"use client"

import { useId, useLayoutEffect, useState } from "react"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { cn } from "@/lib/utils"
import { FormVerifyStudentData } from "./forme_page_1"
import { AppRouterOutputs } from "@/lib/server"
import { FormVerifyParentsData } from "./forme_page_2"
import { ManageGuests } from "./forme_page_3"
import Link from "next/link"

export default function Home() {
  // const session = await getSession()

  // const data = await getGlobalData()

  const [formSection, setFormSection] = useState(1)
  const [studentData, setStudentData] = useState<AppRouterOutputs['verifyStudentData'] | undefined>(undefined)
  const [verificationData, setVerificationData] = useState<AppRouterOutputs['verifyStudentDataWithParents'] | undefined>(undefined)

  return <>
    <div className="text-lg font-medium border-b border-stone-200">
      <div className="container flex max-w-[800px] items-center gap-2">
        <img src="https://www.henryford.edu.ar/favicon.ico" className="max-h-[40px]" alt="Logo" />
        <a href="https://www.henryford.edu.ar" className="py-5">Escuela Técnica Henry Ford</a>
      </div>
    </div>
    <div className="container max-w-[800px]">

      {formSection === 1 && <FormVerifyStudentData onStudentVerified={data => {
        setStudentData(data)
        setFormSection(2)
      }} />}
      {formSection === 2 && <FormVerifyParentsData studentData={studentData} onVerificationCompleted={(v) => {
        setVerificationData(v)
        setFormSection(3)
      }} />}
      {formSection === 3 && <ManageGuests studentData={studentData} verificationData={verificationData} />}
      <hr className="mt-10 mb-4" />
      <p className="font-medium">Formulario de uso exclusivo para la familia de estudiantes de 1° a 7° año de la escuela en 2023 y para ingresantes a primer año 2024.</p>
      <p className="font-medium mt-4">
       Los padres y madres de los estudiantes ya están registrados y no necesitan agregarse como invitados.
      </p>
      <p className="font-medium mt-4">
        Más información en <Link className="hover:underline active:underline text-blue-500" href="https://www.henryford.edu.ar/expo_2023">www.henryford.edu.ar/expo_2023</Link>
      </p>
    </div>
  </>
}
