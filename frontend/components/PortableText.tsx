import { PortableText as PortableTextComponent } from '@portabletext/react'
import { urlFor } from '../sanity/lib/image'

// Portable Text组件配置
const portableTextComponents = {
  types: {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    image: ({ value }: any) => {
      // eslint-disable-next-line @next/next/no-img-element
      return <img src={urlFor(value.asset).url()} alt={value.alt || ''} className="h-auto w-full" />
    },
  },
  marks: {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    link: ({ children, value }: any) => {
      const rel = !value.href.startsWith('/') ? 'noreferrer noopener' : undefined
      return (
        <a href={value.href} rel={rel} className="text-blue-600 underline hover:text-blue-800">
          {children}
        </a>
      )
    },
  },
}

interface PortableTextProps {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  value: any[]
}

export default function PortableText({ value }: PortableTextProps) {
  return <PortableTextComponent value={value} components={portableTextComponents} />
}
