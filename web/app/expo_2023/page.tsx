"use client"

import { useId, useLayoutEffect, useState } from "react"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { cn } from "@/lib/utils"
import { FormVerifyStudentData } from "./forme_page_1"

export default function Home() {
  // const session = await getSession()

  // const data = await getGlobalData()

  const [formPart, setFormPart] = useState(1)


  return <div className="container max-w-[800px]">
    <FormVerifyStudentData />
  </div>

  function nextFormPart() {
    setFormPart((prev) => {
      if (prev >= 3) return prev
      return prev + 1
    })
  }

  function prevFormPart() {
    setFormPart((prev) => {
      if (prev <= 1) return prev
      return prev - 1
    })
  }

  const scrollContainerId = useId()

  useLayoutEffect(() => {
    const div = document.getElementById(`part${formPart}`)
    const scrollContainer = document.getElementById(scrollContainerId)
    if (div && scrollContainer) {
      scrollContainer.scrollTo({
        left: scrollContainer.offsetWidth * (formPart - 1),
        behavior: "smooth",
      })
    }
  }, [formPart])

  function FormPart1() {
    return <>
      <CardHeader>
        <CardTitle>Expo 2023</CardTitle>
        <CardDescription>Explicación formulario expo 2023</CardDescription>
      </CardHeader>
      <CardContent>
        <Label htmlFor="student_dni">DNI Estudiante</Label>
        <Input id="student_dni" placeholder="99.999.999" />
        <div className="h-3" />
        <Label htmlFor="student_enrolment">Matrícula estudiante</Label>
        <Input id="student_enrolment" placeholder="HF9999" />
      </CardContent>
      <CardFooter className="flex justify-between">
        <Button className="ml-auto" onClick={nextFormPart}>Siguiente</Button>
      </CardFooter>
    </>
  }

  function FormPart2() {
    return <>
      <CardHeader>
        <CardTitle>Expo 2023</CardTitle>
        <CardDescription>Explicación formulario expo 2023</CardDescription>
      </CardHeader>
      <CardContent>
        <Label htmlFor="student_dni">DNI (nombre madre)</Label>
        <Input id="mother_dni" placeholder="99.999.999" />
        <div className="h-3" />
        <Label htmlFor="student_enrolment">DNI (nombre padre)</Label>
        <Input id="father_dni" placeholder="99.999.999" />
      </CardContent>
      <CardFooter className="flex justify-between">
        <Button onClick={prevFormPart} variant="outline">Anterior</Button>
        <Button onClick={nextFormPart}>Siguiente</Button>
      </CardFooter>
    </>
  }

  function FormSection(props: { index: number, children: React.ReactNode }) {
    return <div className={cn("w-full h-full overflow-hidden min-w-full snap-center", {
      // "hidden": formPart !== props.index,
    })} id={`part${props.index}`} tabIndex={formPart === props.index ? 0 : -1}>
      {props.children}
    </div>
  }


  return (
    <main className="fixed top-0 right-0 left-0 bottom-0 flex items-center justify-center overflow-auto p-10">
      <Card className="max-w-[100vw] flex overflow-hidden snap-x snap-mandatory" id={scrollContainerId}
        style={{
          width: formPart === 3 ? "600px" : "400px",
          transition: "width 0.5s ease",
        }}
      >
        <FormSection index={1}>
          <FormPart1 />
        </FormSection>
        <FormSection index={2}>
          <FormPart2 />
        </FormSection>
        <FormSection index={3}>
          3
        </FormSection>
      </Card>
    </main>
  )
}
