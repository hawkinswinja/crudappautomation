<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $table = 'Product';
    protected $primaryKey = 'id';
    protected $fillable = [ 'name', 'price' ];
    public $timestamps = false;
}