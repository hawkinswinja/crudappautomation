import React, { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import Service from './Service'

export default function ProductEdit(props) {
  
  const [ product, setProduct ] = useState({})
  
  useEffect(() => {
    get()
  }, [ props.match.params.id ])
  
  function get() {
    return Service.edit(props.match.params.id).then(response => {
      setProduct(response.data)
    }).catch(e => {
      alert(e.response.data)
    })
  }

  function edit(e) {
    e.preventDefault()
    Service.edit(props.match.params.id, product).then(() => {
      props.history.push('/product')
    }).catch((e) => {
      alert(e.response.data)
    })
  }

  function onChange(e) {
    let data = { ...product }
    data[e.target.name] = e.target.value
    setProduct(data)
  }

  return (
    <div className="container">
      <div className="row">
        <div className="col">
          <form method="post" onSubmit={edit}>
            <div className="row">
              <div className="mb-3 col-md-6 col-lg-4">
                <label className="form-label" htmlFor="product_id">Id</label>
                <input readOnly id="product_id" name="id" className="form-control" onChange={onChange} value={product.id ?? '' } type="number" required />
              </div>
              <div className="mb-3 col-md-6 col-lg-4">
                <label className="form-label" htmlFor="product_name">Name</label>
                <input id="product_name" name="name" className="form-control" onChange={onChange} value={product.name ?? '' } maxLength="50" />
              </div>
              <div className="mb-3 col-md-6 col-lg-4">
                <label className="form-label" htmlFor="product_price">Price</label>
                <input id="product_price" name="price" className="form-control" onChange={onChange} value={product.price ?? '' } type="number" />
              </div>
              <div className="col-12">
                <Link className="btn btn-secondary" to="/product">Cancel</Link>
                <button className="btn btn-primary">Submit</button>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  )
}